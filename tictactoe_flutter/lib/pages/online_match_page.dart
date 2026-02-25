import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../game_logic.dart';
import '../supabase_service.dart';
import '../widgets/board.dart';
import '../widgets/toast.dart';

class OnlineMatchPage extends StatefulWidget {
  final dynamic user;
  final String playerEmoji;
  final String joinMode;
  final String roomCodeInput;
  final VoidCallback onHome;

  const OnlineMatchPage({
    super.key,
    required this.user,
    required this.playerEmoji,
    required this.joinMode,
    required this.roomCodeInput,
    required this.onHome,
  });

  @override
  State<OnlineMatchPage> createState() => _OnlineMatchPageState();
}

class _OnlineMatchPageState extends State<OnlineMatchPage> {
  Map<String, dynamic>? _room;
  String? _role; // 'host' | 'guest'
  List<String> _board = List.filled(9, '');
  String _turn = 'host';
  String _status = 'matching'; // matching | waiting_for_guest | playing | done
  String? _result; // win | draw | loss
  String _opponentEmoji = '❓';
  bool _codeCopied = false;

  final List<Map<String, dynamic>> _chats = [];
  final _chatCtrl = TextEditingController();
  final _chatScrollCtrl = ScrollController();
  final _toast = ToastController();

  dynamic _roomSub;
  dynamic _chatSub;

  @override
  void initState() {
    super.initState();
    _toast.bind(setState);
    _init();
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    _chatScrollCtrl.dispose();
    _roomSub?.unsubscribe();
    _chatSub?.unsubscribe();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      Map<String, dynamic> r;
      String myRole;

      if (widget.joinMode == 'create') {
        r = await createRoom(widget.user.id as String, widget.playerEmoji);
        myRole = 'host';
        if (mounted) setState(() => _status = 'waiting_for_guest');
      } else if (widget.joinMode == 'code') {
        r = await joinRoomByCode(
          widget.roomCodeInput,
          widget.user.id as String,
          widget.playerEmoji,
        );
        myRole = 'guest';
      } else {
        // quick match
        final waiting = await findWaitingRoom(widget.user.id as String);
        if (waiting != null) {
          r = await joinRoom(
            waiting['id'] as String,
            widget.user.id as String,
            widget.playerEmoji,
          );
          myRole = 'guest';
        } else {
          r = await createRoom(widget.user.id as String, widget.playerEmoji);
          myRole = 'host';
          if (mounted) setState(() => _status = 'waiting_for_guest');
        }
      }

      if (!mounted) return;
      setState(() {
        _room = r;
        _role = myRole;
        _board = List<String>.from(
          (r['board'] as List).map((e) => e.toString()),
        );
        _turn = r['turn'] as String? ?? 'host';
        if (r['status'] == 'playing') _status = 'playing';
        if (myRole == 'guest') {
          _opponentEmoji = (r['host_emoji'] as String?) ?? '❓';
        }
      });

      _setupSubs(r, myRole);
    } catch (e) {
      if (mounted) _toast.show('Error: ${e.toString()}');
    }
  }

  void _setupSubs(Map<String, dynamic> r, String myRole) {
    _roomSub = subscribeRoom(r['id'] as String, (updated) {
      if (!mounted) return;
      setState(() {
        _board = List<String>.from(
          (updated['board'] as List? ?? []).map((e) => e.toString()),
        );
        _turn = updated['turn'] as String? ?? _turn;
        if (updated['status'] == 'playing') _status = 'playing';
        if (myRole == 'guest') {
          _opponentEmoji = (updated['host_emoji'] as String?) ?? '❓';
        } else {
          _opponentEmoji = (updated['guest_emoji'] as String?) ?? '❓';
        }
        if (updated['status'] == 'done') {
          _status = 'done';
          final winner = updated['winner'] as String?;
          if (winner == myRole) {
            _result = 'win';
          } else if (winner == 'draw') {
            _result = 'draw';
          } else {
            _result = 'loss';
          }
        }
      });
    });

    _chatSub = subscribeChat(r['id'] as String, (msg) {
      if (!mounted) return;
      setState(() => _chats.add(msg));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollCtrl.hasClients) {
          _chatScrollCtrl.animateTo(
            _chatScrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  bool get _isMyTurn => _role == _turn && _status == 'playing';

  Future<void> _handleCellClick(int i) async {
    if (!_isMyTurn || _board[i] != '' || _result != null) return;
    final copy = List<String>.from(_board);
    final mySymbol = _role == 'host' ? 'X' : 'O';
    copy[i] = mySymbol;

    final boardNullable = copy.map((v) => v.isEmpty ? null : v).toList();
    final r = checkResult(boardNullable);
    final newTurn = _turn == 'host' ? 'guest' : 'host';
    String newStatus = 'playing';
    String? winner;
    if (r != null) {
      newStatus = 'done';
      winner = r == 'draw' ? 'draw' : _role;
    }

    try {
      await updateRoom(_room!['id'] as String, {
        'board': copy,
        'turn': newTurn,
        'status': newStatus,
        if (winner != null) 'winner': winner,
      });
    } catch (e) {
      _toast.show('Move failed: $e');
    }
  }

  Future<void> _handleSendChat() async {
    if (_chatCtrl.text.trim().isEmpty) return;
    final name = (widget.user.email as String?)?.split('@').first ?? 'Player';
    await sendChat(
      _room!['id'] as String,
      widget.user.id as String,
      name,
      _chatCtrl.text.trim(),
    );
    _chatCtrl.clear();
  }

  void _copyCode() {
    Clipboard.setData(
      ClipboardData(text: _room?['room_code'] as String? ?? ''),
    );
    setState(() => _codeCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _codeCopied = false);
    });
  }

  Future<void> _shareLink() async {
    final code = _room?['room_code'] as String? ?? '';
    final msg = 'Join my Tic-Tac-Toe game! Code: $code';
    await Share.share(msg);
  }

  Future<void> _handleSignOut() async {
    await signOut();
    widget.onHome();
  }

  // ── Build helpers ──────────────────────────────────────────────────────

  Widget _buildWaitingForGuest() {
    final code = _room?['room_code'] as String? ?? '------';
    final roomUrl = 'https://tictactoe.app/#join:$code';

    return AppPage(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    BackButton2(onTap: widget.onHome, label: '← Cancel'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Room Created! 🏠', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text(
                  'Share the code or QR — waiting for opponent…',
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Main card
                GlowCard(
                  glowColor: AppColors.primary,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'ROOM CODE',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 12,
                          color: AppColors.cyan,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Copy / Share buttons
                      Row(
                        children: [
                          Expanded(
                            child: GlowButton(
                              text: _codeCopied ? '✅ Copied!' : '📋 Copy Code',
                              onTap: _copyCode,
                              ghost: !_codeCopied,
                              color: AppColors.cyan,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlowButton(
                              text: '🔗 Share Link',
                              onTap: _shareLink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'SCAN QR CODE',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: roomUrl,
                          version: QrVersions.auto,
                          size: 180,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Friend scans this → lands straight in your game',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Pulsing waiting indicator
                const _PulseIndicator(),
                const SizedBox(height: 8),
                const Text(
                  'Waiting for opponent to join…',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          ToastOverlay(message: _toast.message),
        ],
      ),
    );
  }

  Widget _buildMatching() {
    return AppPage(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: BackButton2(onTap: widget.onHome),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              const Text('🌐 Finding Match…', style: AppTextStyles.title),
              const SizedBox(height: 32),
              const _PulseIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Searching for an opponent…',
                style: AppTextStyles.subtitle,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          ToastOverlay(message: _toast.message),
        ],
      ),
    );
  }

  Widget _buildGame() {
    final myEmoji = widget.playerEmoji;
    final oppEmoji = _opponentEmoji;
    final mySymbol = _role == 'host' ? 'X' : 'O';

    String statusText;
    if (_result == 'win') {
      statusText = '🏆 You Won!';
    } else if (_result == 'draw') {
      statusText = '🤝 Draw!';
    } else if (_result == 'loss') {
      statusText = '💀 You Lost!';
    } else if (_isMyTurn) {
      statusText = 'Your turn $myEmoji';
    } else {
      statusText = "Opponent's turn $oppEmoji";
    }

    return AppPage(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌐 Online Match',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_room?['room_code'] != null)
                          Text(
                            '#${_room!['room_code']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: _handleSignOut,
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Players
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PlayerBadge2(
                      emoji: myEmoji,
                      label: 'You ($mySymbol)',
                      active: _isMyTurn && _result == null,
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _PlayerBadge2(
                      emoji: oppEmoji,
                      label: 'Opponent',
                      active: !_isMyTurn && _result == null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Status bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _result == 'win'
                            ? AppColors.greenDark
                            : _result == 'loss'
                            ? AppColors.redDark
                            : AppColors.surface2,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color:
                          _result == 'win'
                              ? AppColors.green
                              : _result == 'loss'
                              ? AppColors.red
                              : AppColors.border,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Board
                Expanded(
                  flex: 5,
                  child: Board(
                    board: _board.map((v) => v.isEmpty ? null : v).toList(),
                    onCellClick: _handleCellClick,
                    playerEmoji: _role == 'host' ? myEmoji : oppEmoji,
                    aiEmoji: _role == 'host' ? oppEmoji : myEmoji,
                    disabled: !_isMyTurn || _result != null,
                  ),
                ),

                if (_result != null) ...[
                  const SizedBox(height: 10),
                  GlowButton(
                    text: '🏠 Back to Menu',
                    onTap: widget.onHome,
                    block: true,
                  ),
                ],

                // Chat
                Expanded(
                  flex: 3,
                  child: _ChatSection(
                    chats: _chats,
                    controller: _chatCtrl,
                    scrollController: _chatScrollCtrl,
                    onSend: _handleSendChat,
                  ),
                ),
              ],
            ),
          ),
          ToastOverlay(message: _toast.message),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 'waiting_for_guest' && _room != null) {
      return _buildWaitingForGuest();
    }
    if (_status == 'matching') {
      return _buildMatching();
    }
    return _buildGame();
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _PlayerBadge2 extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;

  const _PlayerBadge2({
    required this.emoji,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGlow : AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ChatSection extends StatelessWidget {
  final List<Map<String, dynamic>> chats;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const _ChatSection({
    required this.chats,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child:
                chats.isEmpty
                    ? const Center(
                      child: Text(
                        'No messages yet…',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    )
                    : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: chats.length,
                      itemBuilder: (ctx, i) {
                        final m = chats[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${m['user_name']}: ',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: m['message'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          // input row
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Say something…',
                      hintStyle: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                TextButton(
                  onPressed: onSend,
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator();

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withAlpha(40),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Icon(Icons.wifi, color: AppColors.primary, size: 28),
      ),
    );
  }
}
