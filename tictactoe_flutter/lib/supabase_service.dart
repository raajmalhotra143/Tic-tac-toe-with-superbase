// Supabase backend service — mirrors React supabase.js exactly
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// ── Auth helpers ──────────────────────────────────────────────────────────

Future<AuthResponse> signUp(String email, String password) async {
  final res = await supabase.auth.signUp(email: email, password: password);
  return res;
}

Future<AuthResponse> signIn(String email, String password) async {
  final res = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  return res;
}

Future<void> signOut() async {
  await supabase.auth.signOut();
}

User? getUser() => supabase.auth.currentUser;

// ── Game room helpers ─────────────────────────────────────────────────────

/// Create a new game room, return the room data
Future<Map<String, dynamic>> createRoom(String hostId, String hostEmoji) async {
  final data =
      await supabase
          .from('rooms')
          .insert({
            'host_id': hostId,
            'host_emoji': hostEmoji,
            'board': ['', '', '', '', '', '', '', '', ''],
            'turn': 'host',
            'status': 'waiting',
          })
          .select()
          .single();
  return data;
}

/// Join an existing waiting room
Future<Map<String, dynamic>> joinRoom(
  String roomId,
  String guestId,
  String guestEmoji,
) async {
  final data =
      await supabase
          .from('rooms')
          .update({
            'guest_id': guestId,
            'guest_emoji': guestEmoji,
            'status': 'playing',
          })
          .eq('id', roomId)
          .eq('status', 'waiting')
          .select()
          .single();
  return data;
}

/// Join a room using its 6-char room code
Future<Map<String, dynamic>> joinRoomByCode(
  String roomCode,
  String guestId,
  String guestEmoji,
) async {
  final rooms = await supabase
      .from('rooms')
      .select('*')
      .eq('room_code', roomCode.toUpperCase().trim())
      .eq('status', 'waiting')
      .limit(1);

  if (rooms.isEmpty) throw Exception('Room not found or already started');
  final room = Map<String, dynamic>.from(rooms[0] as Map);
  if (room['host_id'] == guestId) {
    throw Exception("You can't join your own room");
  }
  return joinRoom(room['id'] as String, guestId, guestEmoji);
}

/// Find first available waiting room (matchmaking)
Future<Map<String, dynamic>?> findWaitingRoom(String userId) async {
  final data = await supabase
      .from('rooms')
      .select('*')
      .eq('status', 'waiting')
      .neq('host_id', userId)
      .order('created_at', ascending: true)
      .limit(1);
  if (data.isEmpty) return null;
  return Map<String, dynamic>.from(data[0] as Map);
}

/// Update board and turn for a room
Future<void> updateRoom(String roomId, Map<String, dynamic> updates) async {
  await supabase.from('rooms').update(updates).eq('id', roomId);
}

/// Subscribe to room changes (Supabase Realtime)
RealtimeChannel subscribeRoom(
  String roomId,
  void Function(Map<String, dynamic>) callback,
) {
  return supabase
      .channel('room:$roomId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'rooms',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: roomId,
        ),
        callback:
            (payload) => callback(Map<String, dynamic>.from(payload.newRecord)),
      )
      .subscribe();
}

/// Send a chat message
Future<void> sendChat(
  String roomId,
  String userId,
  String userName,
  String message,
) async {
  await supabase.from('chats').insert({
    'room_id': roomId,
    'user_id': userId,
    'user_name': userName,
    'message': message,
  });
}

/// Subscribe to chat messages for a room
RealtimeChannel subscribeChat(
  String roomId,
  void Function(Map<String, dynamic>) callback,
) {
  return supabase
      .channel('chat:$roomId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chats',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback:
            (payload) => callback(Map<String, dynamic>.from(payload.newRecord)),
      )
      .subscribe();
}

// ── Leaderboard helpers ───────────────────────────────────────────────────

Future<void> upsertScore(
  String userId,
  String email,
  int wins,
  int losses,
  int draws,
) async {
  await supabase.from('leaderboard').upsert({
    'user_id': userId,
    'email': email,
    'wins': wins,
    'losses': losses,
    'draws': draws,
  }, onConflict: 'user_id');
}

Future<List<Map<String, dynamic>>> getLeaderboard() async {
  final data = await supabase
      .from('leaderboard')
      .select('*')
      .order('wins', ascending: false)
      .limit(20);
  return List<Map<String, dynamic>>.from(
    data.map((e) => Map<String, dynamic>.from(e as Map)),
  );
}
