// Persistent game progress — stored in SharedPreferences
// Mirrors React progress.js (localStorage → SharedPreferences)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'ttt_progress_v2';

Map<String, dynamic> _defaultProgress() => {
  'unlockedLevel': 'easy',
  'easy': {
    'stages': List.generate(15, (_) => {'done': false, 'stars': 0}),
  },
  'normal': {
    'stages': List.generate(15, (_) => {'done': false, 'stars': 0}),
  },
  'impossible': {
    'stages': List.generate(15, (_) => {'done': false, 'stars': 0}),
  },
  'scores': {'wins': 0, 'losses': 0, 'draws': 0},
};

Future<Map<String, dynamic>> getProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_key);
  if (raw == null) return _defaultProgress();
  try {
    return Map<String, dynamic>.from(jsonDecode(raw));
  } catch (_) {
    return _defaultProgress();
  }
}

Future<void> _save(Map<String, dynamic> state) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, jsonEncode(state));
}

Future<Map<String, dynamic>> completeStage(
  String difficulty,
  int stageIndex,
  int stars,
) async {
  final state = await getProgress();
  final arr = List<Map<String, dynamic>>.from(
    state[difficulty]['stages'] as List,
  );
  final prev = arr[stageIndex];
  final prevStars = (prev['stars'] as int?) ?? 0;
  arr[stageIndex] = {
    'done': true,
    'stars': stars > prevStars ? stars : prevStars,
  };
  state[difficulty]['stages'] = arr;

  // Check if all 15 stages complete → unlock next level
  final allDone = arr.every((s) => s['done'] == true);
  if (allDone) {
    if (difficulty == 'easy') state['unlockedLevel'] = 'normal';
    if (difficulty == 'normal') state['unlockedLevel'] = 'impossible';
  }

  await _save(state);
  return state;
}

Future<Map<String, dynamic>> recordScore(String result) async {
  final state = await getProgress();
  final scores = Map<String, dynamic>.from(state['scores'] as Map);
  if (result == 'win') scores['wins'] = (scores['wins'] as int) + 1;
  if (result == 'loss') scores['losses'] = (scores['losses'] as int) + 1;
  if (result == 'draw') scores['draws'] = (scores['draws'] as int) + 1;
  state['scores'] = scores;
  await _save(state);
  return state;
}

Future<void> resetProgress() async {
  await _save(_defaultProgress());
}
