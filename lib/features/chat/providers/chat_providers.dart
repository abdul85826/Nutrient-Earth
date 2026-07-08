import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;
  final StateController<bool> _loadingController;
  final StateController<String?> _errorController;

  ChatMessagesNotifier(
    this._repository,
    this._loadingController,
    this._errorController,
  ) : super([]);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // Add user message to state
    state = [...state, userMessage];
    _loadingController.state = true;
    _errorController.state = null;

    try {
      final aiMessage = await _repository.sendMessage(text);
      state = [...state, aiMessage];
    } catch (e) {
      final errorMsg = _cleanErrorMessage(e.toString());
      _errorController.state = errorMsg;
      print('❌ [CHAT_PROVIDER] Error sending message: $e');
    } finally {
      _loadingController.state = false;
    }
  }

  void clearConversation() {
    state = [];
    _errorController.state = null;
  }

  String _cleanErrorMessage(String error) {
    if (error.contains('SocketException') || error.contains('No internet')) {
      return 'No internet connection. Please check your connection and try again.';
    }
    if (error.contains('TimeoutException') || error.contains('timed out')) {
      return 'Request timed out. The server might be busy. Please try again.';
    }
    if (error.contains('Rate limit') || error.contains('429')) {
      return 'Rate limit exceeded. Please wait a moment before sending another message.';
    }
    if (error.contains('Authentication') || error.contains('401') || error.contains('403')) {
      return 'Authentication error. Please verify the API key setup on the backend.';
    }
    
    // Default clean error
    final clean = error.replaceAll('Exception:', '').replaceAll('HttpException:', '').trim();
    return clean.isNotEmpty ? clean : 'An unexpected error occurred. Please try again.';
  }
}

final chatLoadingProvider = StateProvider<bool>((ref) => false);
final chatErrorProvider = StateProvider<String?>((ref) => null);

final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final loadingController = ref.watch(chatLoadingProvider.notifier);
  final errorController = ref.watch(chatErrorProvider.notifier);
  return ChatMessagesNotifier(repository, loadingController, errorController);
});
