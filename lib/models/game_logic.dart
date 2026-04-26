enum Player { x, o, none }
enum GameMode { twoPlayer, vsAI }
enum Difficulty { easy, medium, hard }
enum GameResult { xWins, oWins, draw, ongoing }

class GameLogic {
  static const List<List<int>> winCombos = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6],             // diags
  ];

  static GameResult checkResult(List<Player> board) {
    for (final combo in winCombos) {
      final a = board[combo[0]], b = board[combo[1]], c = board[combo[2]];
      if (a != Player.none && a == b && b == c) {
        return a == Player.x ? GameResult.xWins : GameResult.oWins;
      }
    }
    if (board.every((p) => p != Player.none)) return GameResult.draw;
    return GameResult.ongoing;
  }

  static List<int>? getWinLine(List<Player> board) {
    for (final combo in winCombos) {
      final a = board[combo[0]], b = board[combo[1]], c = board[combo[2]];
      if (a != Player.none && a == b && b == c) return combo;
    }
    return null;
  }

  static int? getAIMove(List<Player> board, Difficulty difficulty) {
    final empty = _getEmpty(board);
    if (empty.isEmpty) return null;

    switch (difficulty) {
      case Difficulty.easy:
        empty.shuffle();
        return empty.first;

      case Difficulty.medium:
        // Win if can
        final win = _findWinMove(board, Player.o);
        if (win != null) return win;
        // Block X
        final block = _findWinMove(board, Player.x);
        if (block != null) return block;
        // Take center or random
        if (board[4] == Player.none) return 4;
        empty.shuffle();
        return empty.first;

      case Difficulty.hard:
        final result = _minimax(board, true, -1000, 1000, 0);
        return result['move'] as int?;
    }
  }

  static int? _findWinMove(List<Player> board, Player player) {
    for (final i in _getEmpty(board)) {
      final b = List<Player>.from(board);
      b[i] = player;
      if (checkResult(b) == (player == Player.x ? GameResult.xWins : GameResult.oWins)) {
        return i;
      }
    }
    return null;
  }

  static List<int> _getEmpty(List<Player> board) =>
      [for (int i = 0; i < 9; i++) if (board[i] == Player.none) i];

  static Map<String, dynamic> _minimax(
    List<Player> board,
    bool isMaximizing,
    int alpha,
    int beta,
    int depth,
  ) {
    final result = checkResult(board);
    if (result == GameResult.oWins) return {'score': 10 - depth, 'move': null};
    if (result == GameResult.xWins) return {'score': depth - 10, 'move': null};
    if (result == GameResult.draw) return {'score': 0, 'move': null};

    int bestScore = isMaximizing ? -1000 : 1000;
    int? bestMove;

    for (final i in _getEmpty(board)) {
      final b = List<Player>.from(board);
      b[i] = isMaximizing ? Player.o : Player.x;
      final res = _minimax(b, !isMaximizing, alpha, beta, depth + 1);
      final score = res['score'] as int;

      if (isMaximizing ? score > bestScore : score < bestScore) {
        bestScore = score;
        bestMove = i;
      }

      if (isMaximizing) {
        alpha = alpha > bestScore ? alpha : bestScore;
      } else {
        beta = beta < bestScore ? beta : bestScore;
      }
      if (beta <= alpha) break;
    }

    return {'score': bestScore, 'move': bestMove};
  }
}

class GameState {
  List<Player> board;
  Player currentPlayer;
  GameResult result;
  List<int>? winLine;
  int xScore;
  int oScore;
  int draws;
  GameMode mode;
  Difficulty difficulty;
  List<String> history;

  GameState({
    List<Player>? board,
    this.currentPlayer = Player.x,
    this.result = GameResult.ongoing,
    this.winLine,
    this.xScore = 0,
    this.oScore = 0,
    this.draws = 0,
    this.mode = GameMode.twoPlayer,
    this.difficulty = Difficulty.hard,
    List<String>? history,
  })  : board = board ?? List.filled(9, Player.none),
        history = history ?? [];

  GameState copyWith({
    List<Player>? board,
    Player? currentPlayer,
    GameResult? result,
    List<int>? winLine,
    int? xScore,
    int? oScore,
    int? draws,
    GameMode? mode,
    Difficulty? difficulty,
    List<String>? history,
    bool clearWinLine = false,
  }) {
    return GameState(
      board: board ?? List.from(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      result: result ?? this.result,
      winLine: clearWinLine ? null : (winLine ?? this.winLine),
      xScore: xScore ?? this.xScore,
      oScore: oScore ?? this.oScore,
      draws: draws ?? this.draws,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      history: history ?? List.from(this.history),
    );
  }
}
