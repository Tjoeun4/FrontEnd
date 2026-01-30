class RecommendResponse {
  final int userId;
  final List<Recipe> recipes;

  RecommendResponse({required this.userId, required this.recipes});

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    return RecommendResponse(
      userId: json['userId'],
      recipes: (json['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList(),
    );
  }
}

class Recipe {
  final String title;
  final String summary;
  final int timeMinutes;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final String photoUrl;

  Recipe({
    required this.title,
    required this.summary,
    required this.timeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.photoUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      summary: json['summary'],
      timeMinutes: json['timeMinutes'],
      difficulty: json['difficulty'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      photoUrl: json['photoUrl'],
    );
  }

  // 난이도 한글 변환 유틸리티
  String get difficultyKorean {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return '쉬움';
      case 'MEDIUM':
        return '보통';
      case 'HARD':
        return '어려움';
      default:
        return difficulty;
    }
  }
}
