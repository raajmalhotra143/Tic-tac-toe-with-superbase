import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/welcome_page.dart';
import 'pages/mode_page.dart';
import 'pages/emoji_select_page.dart';
import 'pages/level_select_page.dart';
import 'pages/stage_select_page.dart';
import 'pages/offline_game_page.dart';
import 'pages/auth_page.dart';
import 'pages/online_emoji_page.dart';
import 'pages/online_match_page.dart';

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic·Tac·Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

// ── App-level state machine (mirrors React App.jsx) ──────────────────────────
enum AppScreen {
  welcome,
  mode,
  emojiSelect,
  levelSelect,
  stageSelect,
  offlineGame,
  auth,
  onlineEmoji,
  onlineMatch,
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  AppScreen _screen = AppScreen.welcome;
  String _playerEmoji = '🦊';
  String _aiEmoji = '🤖';
  String _difficulty = 'easy';
  int _stageIndex = 0;
  dynamic _user;
  String _onlineEmoji = '🦁';
  String _joinMode = 'quick';
  String _roomCodeInput = '';

  void _go(AppScreen s) => setState(() => _screen = s);

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case AppScreen.welcome:
        return WelcomePage(onPlay: () => _go(AppScreen.mode));

      case AppScreen.mode:
        return ModePage(
          onBack: () => _go(AppScreen.welcome),
          onSelectMode: (m) {
            if (m == 'offline') {
              _go(AppScreen.emojiSelect);
            } else {
              _go(AppScreen.auth);
            }
          },
        );

      case AppScreen.emojiSelect:
        return EmojiSelectPage(
          onBack: () => _go(AppScreen.mode),
          onConfirm: (pe, ae) {
            setState(() {
              _playerEmoji = pe;
              _aiEmoji = ae;
            });
            _go(AppScreen.levelSelect);
          },
        );

      case AppScreen.levelSelect:
        return LevelSelectPage(
          onBack: () => _go(AppScreen.emojiSelect),
          onSelectLevel: (lv) {
            setState(() => _difficulty = lv);
            _go(AppScreen.stageSelect);
          },
        );

      case AppScreen.stageSelect:
        return StageSelectPage(
          difficulty: _difficulty,
          onBack: () => _go(AppScreen.levelSelect),
          onSelectStage: (idx) {
            setState(() => _stageIndex = idx);
            _go(AppScreen.offlineGame);
          },
        );

      case AppScreen.offlineGame:
        return OfflineGamePage(
          difficulty: _difficulty,
          stageIndex: _stageIndex,
          playerEmoji: _playerEmoji,
          aiEmoji: _aiEmoji,
          onHome: () => _go(AppScreen.levelSelect),
          onNextStage: (nextIdx) {
            if (nextIdx < 15) {
              setState(() => _stageIndex = nextIdx);
              _go(AppScreen.offlineGame);
            } else {
              _go(AppScreen.stageSelect);
            }
          },
        );

      case AppScreen.auth:
        return AuthPage(
          onBack: () => _go(AppScreen.mode),
          onAuth: (u) {
            setState(() => _user = u);
            _go(AppScreen.onlineEmoji);
          },
        );

      case AppScreen.onlineEmoji:
        return OnlineEmojiPage(
          onBack: () => _go(AppScreen.mode),
          onConfirm: (em, mode, code) {
            setState(() {
              _onlineEmoji = em;
              _joinMode = mode;
              _roomCodeInput = code;
            });
            _go(AppScreen.onlineMatch);
          },
        );

      case AppScreen.onlineMatch:
        return OnlineMatchPage(
          user: _user,
          playerEmoji: _onlineEmoji,
          joinMode: _joinMode,
          roomCodeInput: _roomCodeInput,
          onHome: () => _go(AppScreen.mode),
        );
    }
  }
}
