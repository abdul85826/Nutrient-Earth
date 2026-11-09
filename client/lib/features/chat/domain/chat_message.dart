// ==============================================================================
// Nutrient Earth — One Interface Conversational Domain Model
// Represents a single turn in the continuous health intelligence stream.
// Supports adaptive capabilities (markdown, Atwater tables, citations, action checklists).
// ==============================================================================

import 'package:uuid/uuid.dart';
import '../../../../core/domain/nutrition/nutrition_computation_engine.dart';
import '../../../../core/services/nutrition/usda_food_data_central_provider.dart';
import '../../../../core/services/research_pipeline_service.dart';
import '../../../../core/domain/memory/personal_health_memory_models.dart';
import '../../../../core/services/summary/doctor_summary_service.dart';

enum ChatRole {
  user,
  assistant,
  system;

  String get label => name;
}

enum ChatCapabilityType {
  ordinaryConversation,
  nutritionCalculation,
  scientificResearch,
  goalActionPlan,
  healthMemoryReview,
  doctorSummary,
  multimodalAnalysis;

  String get displayName {
    switch (this) {
      case ChatCapabilityType.ordinaryConversation:
        return 'Dialogue';
      case ChatCapabilityType.nutritionCalculation:
        return 'Nutrition Calculation';
      case ChatCapabilityType.scientificResearch:
        return 'Scientific Research';
      case ChatCapabilityType.goalActionPlan:
        return 'Goal & Action Protocol';
      case ChatCapabilityType.healthMemoryReview:
        return 'Health Memory Review';
      case ChatCapabilityType.doctorSummary:
        return 'Doctor Consultation Brief';
      case ChatCapabilityType.multimodalAnalysis:
        return 'Multimodal Inspection';
    }
  }
}

class ChatAttachment {
  final String id;
  final String fileName;
  final String mimeType;
  final String? localPath;
  final int? fileSizeBytes;

  const ChatAttachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    this.localPath,
    this.fileSizeBytes,
  });

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';
  bool get isAudio => mimeType.startsWith('audio/');
}

class ChatActionItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final String? scheduledTime;

  const ChatActionItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.isCompleted = false,
    this.scheduledTime,
  });

  ChatActionItem copyWith({
    bool? isCompleted,
    String? title,
    String? subtitle,
    String? scheduledTime,
  }) {
    return ChatActionItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'isCompleted': isCompleted,
        'scheduledTime': scheduledTime,
      };

  factory ChatActionItem.fromJson(Map<String, dynamic> json) {
    return ChatActionItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      isCompleted: json['isCompleted'] == true,
      scheduledTime: json['scheduledTime'] as String?,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final ChatRole role;
  final String text;
  final DateTime timestamp;
  final ChatCapabilityType capabilityType;
  final List<ChatAttachment> attachments;
  final List<ChatActionItem> actionItems;
  final List<ResearchCitation> citations;
  final MacronutrientEnergyBreakdown? energyBreakdown;
  final UsdaFoodItem? foodItem;
  final List<HealthMemoryRecord>? healthMemoryDrafts;
  final DoctorConsultationSummary? doctorSummary;
  final bool isStreaming;
  final bool isError;
  final String? errorMessage;
  final String? evidenceBadge;
  final String? mechanismCallout;
  final String? disclaimer;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    required this.timestamp,
    this.capabilityType = ChatCapabilityType.ordinaryConversation,
    this.attachments = const [],
    this.actionItems = const [],
    this.citations = const [],
    this.energyBreakdown,
    this.foodItem,
    this.healthMemoryDrafts,
    this.doctorSummary,
    this.isStreaming = false,
    this.isError = false,
    this.errorMessage,
    this.evidenceBadge,
    this.mechanismCallout,
    this.disclaimer,
  });

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
  bool get isSystem => role == ChatRole.system;

  ChatMessage copyWith({
    String? text,
    bool? isStreaming,
    bool? isError,
    String? errorMessage,
    List<ChatActionItem>? actionItems,
    List<ResearchCitation>? citations,
    List<HealthMemoryRecord>? healthMemoryDrafts,
    DoctorConsultationSummary? doctorSummary,
    ChatCapabilityType? capabilityType,
    String? evidenceBadge,
    String? mechanismCallout,
    String? disclaimer,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
      capabilityType: capabilityType ?? this.capabilityType,
      attachments: attachments,
      actionItems: actionItems ?? this.actionItems,
      citations: citations ?? this.citations,
      energyBreakdown: energyBreakdown,
      foodItem: foodItem,
      healthMemoryDrafts: healthMemoryDrafts ?? this.healthMemoryDrafts,
      doctorSummary: doctorSummary ?? this.doctorSummary,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      evidenceBadge: evidenceBadge ?? this.evidenceBadge,
      mechanismCallout: mechanismCallout ?? this.mechanismCallout,
      disclaimer: disclaimer ?? this.disclaimer,
    );
  }
}

