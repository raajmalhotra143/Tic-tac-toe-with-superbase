import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../game_logic.dart';
import '../progress.dart';
import '../widgets/board.dart';
import '../widgets/result_overlay.dart';

class OfflineGamePage extends StatefulWidget {
  final String difficulty;
  final int stageIndex;
  final String playerEmoji;
  final String aiEmoji;
  final VoidCallback onHome;
  final void Function(int nextIdx) onNextStage;

  const OfflineGamePage({
    super.key,
    required this.difficulty,
    required this.stageIndex,
    required this.playerEmoji,
    required this.aiEmoji,
    required this.onHome,
    required this.onNextStage,
  });

  @override
  State<OfflineGamePage> createState() => _OfflineGamePageState();
}

class _OfflineGamePageState extends State<OfflineGamePage> {
  List<String?> _board = List.filled(9, null);
  bool _playerTurn = true;
  String? _result; // null | 'win' | 'draw' | 'loss'
  int _moves = 0;
  int _stars = 0;
  bool _thinking = false;
  Timer? _aiTimer;

  int get _stage => widget.stageIndex + 1; // 1-based
  bool get _isLast => widget.stageIndex == 14;

  @override
  void dispose() {
    _aiTimer?.cancel();
    super.dispose();
  }

  void _handleResult(String r, int moveCount) {
    final bool force = isForceImpossibleStage(_stage, widget.difficulty);
    final mapped =
        r == 'X'
            ? 'win'
            : r == 'O'
            ? 'loss'
            : 'draw';
    final final0 = force && mapped == 'win' ? 'draw' : mapped;
    final s = final0 == 'win' ? calcStars(moveCount) : 0;

    setState(() {
      _stars = s;
      _result = final0;
    });

    completeStage(widget.difficulty, widget.stageIndex, s);
    recordScore(final0);
  }

  void _triggerAI() {
    if (_playerTurn || _result != null) return;
    setState(() => _thinking = true);

    final delay = 400 + (DateTime.now().millisecondsSinceEpoch % 300);
    _aiTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final copy = List<String?>.from(_board);
      final idx = getAIMove(copy, widget.difficulty, stage: _stage);
      if (idx == null) return;
      copy[idx] = 'O';
      final r = checkResult(copy);
      final newMoves = _moves + 1;
      setState(() {
        _board = copy;
        _moves = newMoves;
        _thinking = false;
      });
      if (r != null) {
        _handleResult(r, newMoves);
      } else {
        setState(() => _playerTurn = true);
      }
    });
  }

  void _handleCellClick(int i) {
    if (!_playerTurn || _result != null || _board[i] != null || _thinking) {
      return;
    }
    final copy = List<String?>.from(_board);
    copy[i] = 'X';
    final newMoves = _moves + 1;
    setState(() {
      _board = copy;
      _moves = newMoves;
    });
    final r = checkResult(copy);
    if (r != null) {
      _handleResult(r, newMoves);
    } else {
      setState(() => _playerTurn = false);
      _triggerAI();
    }
  }

  void _replay() {
    _aiTimer?.cancel();
    setState(() {
      _board = List.filled(9, null);
      _playerTurn = true;
      _result = null;
      _moves = 0;
      _stars = 0;
      _thinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diffLabel =
        {'easy': '🌱', 'normal': '⚔️', 'impossible': '💀'}[widget.difficulty]!;
    final statusText =
        _thinking
            ? '🤔 AI is thinking…'
            : _playerTurn
            ? 'Your turn ${widget.playerEmoji}'
            : "Opponent's turn ${widget.aiEmoji}";

    return AppPage(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button row
                Row(
                  children: [
                    BackButton2(onTap: widget.onHome, label: '← Menu'),
                  ],
                ),
                const SizedBox(height: 8),

                // Stage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '$diffLabel Stage $_stage / 15',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Player vs AI badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PlayerBadge(
                      emoji: widget.playerEmoji,
                      label: 'You',
                      active: _playerTurn && _result == null,
                    ),
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    _PlayerBadge(
                      emoji: widget.aiEmoji,
                      label: 'AI',
                      active: !_playerTurn && _result == null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDim,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Board
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Board(
                      board: _board,
                      onCellClick: _handleCellClick,
                      playerEmoji: widget.playerEmoji,
                      aiEmoji: widget.aiEmoji,
                      disabled: !_playerTurn || _result != null || _thinking,
                    ),
                  ),
                ),
              ],
            ),

            // Result overlay
            if (_result != null)
              Positioned.fill(
                child: ResultOverlay(
                  result: _result!,
                  stars: _stars,
                  moves: _moves,
                  playerEmoji: widget.playerEmoji,
                  aiEmoji: widget.aiEmoji,
                  isLastStage: _isLast,
                  onNextStage: () => widget.onNextStage(widget.stageIndex + 1),
                  onReplay: _replay,
                  onHome: widget.onHome,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;

  const _PlayerBadge({
    required this.emoji,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGlow : AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
          width: active ? 2 : 1,
        ),
        boxShadow:
            active
                ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 16,
                  ),
                ]
                : null,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
