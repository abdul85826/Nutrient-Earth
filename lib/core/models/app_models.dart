class ActionStep {
  final String id;
  final String title;
  final String instruction;
  final String benefit;
  final bool isCompleted;
  final bool isLocked;

  ActionStep({
    required this.id,
    required this.title,
    required this.instruction,
    required this.benefit,
    this.isCompleted = false,
    this.isLocked = true,
  });

  ActionStep copyWith({
    bool? isCompleted,
    bool? isLocked,
  }) {
    return ActionStep(
      id: id,
      title: title,
      instruction: instruction,
      benefit: benefit,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'instruction': instruction,
      'benefit': benefit,
      'is_completed': isCompleted,
      'is_locked': isLocked,
    };
  }

  factory ActionStep.fromMap(Map<String, dynamic> map) {
    return ActionStep(
      id: map['id'],
      title: map['title'],
      instruction: map['instruction'],
      benefit: map['benefit'],
      isCompleted: map['is_completed'] ?? false,
      isLocked: map['is_locked'] ?? true,
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String benefit;
  final List<String> primaryHerbs;
  final String imagePath; // Local assets or dummy URLs

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.benefit,
    required this.primaryHerbs,
    required this.imagePath,
  });
}

class SuccessStory {
  final String id;
  final String name;
  final String beforeValue;
  final String afterValue;
  final int days;
  final String problemType; // sugar, weight, stress
  final String shortStory;

  SuccessStory({
    required this.id,
    required this.name,
    required this.beforeValue,
    required this.afterValue,
    required this.days,
    required this.problemType,
    required this.shortStory,
  });
}
