import '../models/chat_message.dart';
import '../services/chat_api_client.dart';

class ChatRepository {
  final ChatApiClient _apiClient;

  ChatRepository({ChatApiClient? apiClient})
      : _apiClient = apiClient ?? ChatApiClient();

  Future<ChatMessage> sendMessage(String text) async {
    final replyText = await _apiClient.sendMessage(text);
    return ChatMessage(
      text: replyText,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );
  }
}
