import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';

class ChatApiClient {
  final SupabaseClient _client;

  ChatApiClient([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      throw const FormatException('Message cannot be empty.');
    }

    final startTime = DateTime.now();
    try {
      print('✓ [CHAT_API] Request Sent: "${message.substring(0, message.length > 30 ? 30 : message.length)}..."');
      print('✓ [CHAT_API] Edge Function Called: "chat"');

      final response = await _client.functions.invoke(
        'chat',
        body: {'message': message},
      ).timeout(const Duration(seconds: 25)); // 25s timeout for Groq API

      final duration = DateTime.now().difference(startTime);
      print('✓ [CHAT_API] Groq Response Time: ${duration.inMilliseconds}ms');

      final data = response.data;
      if (response.status != 200 || data == null) {
        print('❌ [CHAT_API] Edge Function returned error status: ${response.status}');
        if (data is Map && data.containsKey('error')) {
          throw HttpException('Error: ${data['error']}');
        }
        throw HttpException('Server returned status ${response.status}');
      }

      if (data is Map && data.containsKey('response')) {
        final reply = data['response'] as String;
        print('✓ [CHAT_API] Response Received: "${reply.substring(0, reply.length > 30 ? 30 : reply.length)}..."');
        return reply;
      } else if (data is Map && data.containsKey('error')) {
        throw HttpException(data['error'] as String);
      } else {
        throw const FormatException('Invalid response format');
      }
    } on FunctionException catch (e) {
      print('❌ [CHAT_API] Supabase FunctionException: $e (status: ${e.status})');
      if (e.status == 429) {
        throw const HttpException('Rate limit exceeded. Please try again later.');
      } else if (e.status == 401 || e.status == 403) {
        throw const HttpException('Authentication/API Key error. Please check configuration.');
      }
      throw HttpException('Supabase function error: $e');
    } on TimeoutException {
      print('❌ [CHAT_API] Groq timeout');
      throw TimeoutException('Request timed out. Please check your connection.');
    } on SocketException {
      print('❌ [CHAT_API] No internet');
      throw const SocketException('No internet connection. Please verify your network.');
    } catch (e) {
      print('❌ [CHAT_API] Error: $e');
      if (e.toString().contains('SocketException')) {
        throw const SocketException('No internet connection. Please verify your network.');
      }
      rethrow;
    }
  }
}
