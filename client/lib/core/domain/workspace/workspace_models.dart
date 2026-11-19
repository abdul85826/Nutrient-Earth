// ==============================================================================
// Nutrient Earth — Intelligence Workspace Domain Models
// Defines conversations, research projects, saved intelligence items, and universal search.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum SavedItemType {
  answer('answer', 'Saved Answer'),
  researchPaper('research_paper', 'Scientific Paper'),
  productAnalysis('product_analysis', 'Product Inspection'),
  plan('plan', 'Personal Protocol / Plan'),
  calculation('calculation', 'Nutrition Calculation'),
  report('report', 'Clinical / Doctor Summary');

  final String value;
  final String label;

  const SavedItemType(this.value, this.label);

  static SavedItemType fromString(String val) {
    return SavedItemType.values.firstWhere(
      (s) => s.value == val,
      orElse: () => SavedItemType.answer,
    );
  }
}

class WorkspaceConversation {
  final String id;
  final String userId;
  final String title;
  final String? projectId;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkspaceConversation({
    required this.id,
    required this.userId,
    required this.title,
    this.projectId,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkspaceConversation.create({
    required String userId,
    required String title,
    String? projectId,
  }) {
    final now = DateTime.now().toUtc();
    return WorkspaceConversation(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      projectId: projectId,
      createdAt: now,
      updatedAt: now,
    );
  }

  WorkspaceConversation copyWith({
    String? title,
    String? projectId,
    bool? isPinned,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return WorkspaceConversation(
      id: id,
      userId: userId,
      title: title ?? this.title,
      projectId: projectId ?? this.projectId,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  factory WorkspaceConversation.fromJson(Map<String, dynamic> json) {
    return WorkspaceConversation(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Conversation',
      projectId: json['project_id'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      if (projectId != null) 'project_id': projectId,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WorkspaceProject {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String colorHex;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkspaceProject({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.colorHex = '#00251D',
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkspaceProject.create({
    required String userId,
    required String name,
    String? description,
    String colorHex = '#00251D',
  }) {
    final now = DateTime.now().toUtc();
    return WorkspaceProject(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory WorkspaceProject.fromJson(Map<String, dynamic> json) {
    return WorkspaceProject(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Project',
      description: json['description'] as String?,
      colorHex: json['color_hex'] as String? ?? '#00251D',
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      if (description != null) 'description': description,
      'color_hex': colorHex,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WorkspaceSavedItem {
  final String id;
  final String userId;
  final String? projectId;
  final String title;
  final SavedItemType itemType;
  final String contentSnippet;
  final Map<String, dynamic> payload;
  final String? sourceReference;
  final DateTime createdAt;

  const WorkspaceSavedItem({
    required this.id,
    required this.userId,
    this.projectId,
    required this.title,
    required this.itemType,
    required this.contentSnippet,
    this.payload = const {},
    this.sourceReference,
    required this.createdAt,
  });

  factory WorkspaceSavedItem.create({
    required String userId,
    String? projectId,
    required String title,
    required SavedItemType itemType,
    required String contentSnippet,
    Map<String, dynamic> payload = const {},
    String? sourceReference,
  }) {
    return WorkspaceSavedItem(
      id: const Uuid().v4(),
      userId: userId,
      projectId: projectId,
      title: title,
      itemType: itemType,
      contentSnippet: contentSnippet,
      payload: payload,
      sourceReference: sourceReference,
      createdAt: DateTime.now().toUtc(),
    );
  }

  factory WorkspaceSavedItem.fromJson(Map<String, dynamic> json) {
    return WorkspaceSavedItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      projectId: json['project_id'] as String?,
      title: json['title'] as String? ?? 'Saved Item',
      itemType: SavedItemType.fromString(json['item_type'] as String? ?? ''),
      contentSnippet: json['content_snippet'] as String? ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : const {},
      sourceReference: json['source_reference'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (projectId != null) 'project_id': projectId,
      'title': title,
      'item_type': itemType.value,
      'content_snippet': contentSnippet,
      'payload': payload,
      if (sourceReference != null) 'source_reference': sourceReference,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum SearchResultSourceType {
  conversation('conversation', 'Conversation Title'),
  message('message', 'Chat Message'),
  project('project', 'Research Project'),
  savedItem('saved_item', 'Saved Intelligence'),
  researchDocument('research_document', 'Scientific Evidence');

  final String value;
  final String label;

  const SearchResultSourceType(this.value, this.label);
}

class UniversalSearchResult {
  final String id;
  final String title;
  final String snippet;
  final SearchResultSourceType sourceType;
  final String entityId;
  final DateTime createdAt;

  const UniversalSearchResult({
    required this.id,
    required this.title,
    required this.snippet,
    required this.sourceType,
    required this.entityId,
    required this.createdAt,
  });
}
