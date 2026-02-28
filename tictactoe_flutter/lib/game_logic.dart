// Game logic — AI, win detection, star rating
// Mirrors React gameLogic.js exactly

const List<List<int>> winLines = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  [0, 4, 8],
  [2, 4, 6],
];

/// Returns winning symbol ('X'|'O'), 'draw', or null
String? checkResult(List<String?> board) {
  for (final line in winLines) {
    final a = line[0], b = line[1], c = line[2];
    if (board[a] != null && board[a] == board[b] && board[a] == board[c]) {
      return board[a];
    }
  }
  return board.every((v) => v != null) ? 'draw' : null;
}

/// Returns indices of the winning line, or []
List<int> getWinLine(List<String?> board) {
  for (final line in winLines) {
    final a = line[0], b = line[1], c = line[2];
    if (board[a] != null && board[a] == board[b] && board[a] == board[c]) {
      return line;
    }
  }
  return [];
}

// minimax with alpha-beta pruning
int _minimax(List<String?> board, bool isMax, int alpha, int beta, int depth) {
  final result = checkResult(board);
  if (result == 'O') return 10 - depth;
  if (result == 'X') return depth - 10;
  if (result == 'draw') return 0;

  if (isMax) {
    int best = -999;
    for (int i = 0; i < 9; i++) {
      if (board[i] == null) {
        board[i] = 'O';
        best = _max(best, _minimax(board, false, alpha, beta, depth + 1));
        board[i] = null;
        alpha = _max(alpha, best);
        if (beta <= alpha) break;
      }
    }
    return best;
  } else {
    int best = 999;
    for (int i = 0; i < 9; i++) {
      if (board[i] == null) {
        board[i] = 'X';
        best = _min(best, _minimax(board, true, alpha, beta, depth + 1));
        board[i] = null;
        beta = _min(beta, best);
        if (beta <= alpha) break;
      }
    }
    return best;
  }
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;

/// Perfect AI move index
int? _bestMove(List<String?> board) {
  int best = -999;
  int? idx;
  for (int i = 0; i < 9; i++) {
    if (board[i] == null) {
      board[i] = 'O';
      final score = _minimax(board, false, -999, 999, 0);
      board[i] = null;
      if (score > best) {
        best = score;
        idx = i;
      }
    }
  }
  return idx;
}

/// Semi-smart: sometimes picks suboptimal move
int? _normalMove(List<String?> board) {
  if ((DateTime.now().millisecond % 4) == 0) return _randomMove(board);
  return _bestMove(board);
}

int? _randomMove(List<String?> board) {
  final empty = <int>[];
  for (int i = 0; i < 9; i++) {
    if (board[i] == null) empty.add(i);
  }
  if (empty.isEmpty) return null;
  empty.shuffle();
  return empty.first;
}

/// Get AI move index for a given difficulty and stage
int? getAIMove(List<String?> board, String difficulty, {int stage = 1}) {
  final empty = <int>[];
  for (int i = 0; i < 9; i++) {
    if (board[i] == null) empty.add(i);
  }
  if (empty.isEmpty) return null;

  final rand = DateTime.now().millisecondsSinceEpoch % 100;

  if (difficulty == 'easy') {
    // Stage 1-5: fully random; 6-10: 10% smart; 11-15: 30% smart
    final smartChance =
        stage <= 5
            ? 0
            : stage <= 10
            ? 10
            : 30;
    return rand < smartChance ? _normalMove(board) : _randomMove(board);
  }

  if (difficulty == 'normal') {
    // Stage 1-5: 10% smart; 6-10: 50% smart; 11-15: 80% smart
    final smartChance =
        stage <= 5
            ? 10
            : stage <= 10
            ? 50
            : 80;
    return rand < smartChance ? _bestMove(board) : _randomMove(board);
  }

  // impossible — always perfect
  return _bestMove(board);
}

/// Stars: 3→3 moves, 4→2 moves, 5→1 move, 6+→0
int calcStars(int moves) {
  if (moves <= 3) return 3;
  if (moves <= 4) return 2;
  if (moves <= 5) return 1;
  return 0;
}

/// Check if the impossible stage 15 is forced loss/tie
bool isForceImpossibleStage(int stage, String difficulty) {
  return difficulty == 'impossible' && stage == 15;
}
