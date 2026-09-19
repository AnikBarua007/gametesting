enum WordDifficulty {
  easy,
  medium,
  hard,
}

extension WordDifficultyExt on WordDifficulty {
  int get basePoints {
    switch (this) {
      case WordDifficulty.easy:
        return 100;
      case WordDifficulty.medium:
        return 200;
      case WordDifficulty.hard:
        return 300;
    }
  }

  String get label {
    switch (this) {
      case WordDifficulty.easy:
        return 'EASY';
      case WordDifficulty.medium:
        return 'MEDIUM';
      case WordDifficulty.hard:
        return 'HARD';
    }
  }
}

class SketchPartyWord {
  final String word;
  final String category;
  final WordDifficulty difficulty;
  final List<String> synonyms;
  final String hint;

  const SketchPartyWord({
    required this.word,
    required this.category,
    required this.difficulty,
    this.synonyms = const <String>[],
    this.hint = '',
  });

  /// Check if a guess matches the target word or any accepted synonyms.
  bool matches(String guess) {
    final String clean = guess.trim().toLowerCase();
    if (clean == word.toLowerCase()) return true;
    for (final String syn in synonyms) {
      if (clean == syn.toLowerCase()) return true;
    }
    return false;
  }

  /// Calculates Levenshtein edit distance to identify close guesses.
  static int levenshtein(String a, String b) {
    final String s1 = a.trim().toLowerCase();
    final String s2 = b.trim().toLowerCase();
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (int i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        final int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = <int>[
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((int curr, int next) => curr < next ? curr : next);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  /// Returns true if guess is off by only 1 character (for "You're close!" feedback).
  bool isClose(String guess) {
    final String clean = guess.trim().toLowerCase();
    if (clean.length < 3) return false;
    final int dist = levenshtein(clean, word.toLowerCase());
    return dist == 1;
  }
}

