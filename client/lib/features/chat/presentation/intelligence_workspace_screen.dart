// ==============================================================================
// Nutrient Earth — Intelligence Workspace Screen
// The integrated personal intelligence workspace:
// - Left: Persistent, collapsible IntelligenceWorkspaceSidebar (or Drawer on mobile)
// - Center: Multi-turn streaming intelligence dialogue with ChatMessageTile
// - Docked: UnifiedChatComposer supporting multimodal triggers
// - Top-Right: Direct link to Control Centre & Profile
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/auth_service.dart';
import '../state/chat_stream_notifier.dart';
import 'widgets/chat_message_tile.dart';
import 'widgets/intelligence_workspace_sidebar.dart';
import 'widgets/unified_chat_composer.dart';

class IntelligenceWorkspaceScreen extends ConsumerStatefulWidget {
  const IntelligenceWorkspaceScreen({super.key});

  @override
  ConsumerState<IntelligenceWorkspaceScreen> createState() =>
      _IntelligenceWorkspaceScreenState();
}

class _IntelligenceWorkspaceScreenState
    extends ConsumerState<IntelligenceWorkspaceScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSidebarCollapsed = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatStreamProvider);
    final auth = ref.watch(authServiceProvider);
    final user = auth.currentUser;

    // Trigger scroll when message count changes
    ref.listen(chatStreamProvider.select((s) => s.messages.length), (_, __) {
      _scrollToBottom();
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Canonical Warm Cream
      drawer: isDesktop
          ? null
          : const Drawer(
              child: IntelligenceWorkspaceSidebar(isDrawer: true),
            ),
      body: Row(
        children: [
          // Persistent Desktop Sidebar
          if (isDesktop)
            IntelligenceWorkspaceSidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggleCollapse: () {
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
              },
            ),

          // Main Intelligence Workspace Center Region
          Expanded(
            child: Column(
              children: [
                // Top Workspace Navigation Bar
                _buildTopBar(context, isDesktop, user?.email),

                // Conversation Message Stream
                Expanded(
                  child: chatState.messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final msg = chatState.messages[index];
                            return ChatMessageTile(
                              message: msg,
                              onActionItemToggled: (actionId) {
                                // Toggle action item state
                              },
                              onAcceptAllActions: () {
                                // Add action plan to daily tasks
                              },
                              onRetry: () {
                                // Retry last failed inquiry
                              },
                            );
                          },
                        ),
                ),

                // Docked Chat Composer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF00251D).withOpacity(0.06),
                      ),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: UnifiedChatComposer(
                        isGenerating: chatState.isGenerating,
                        onSubmitted: (text) {
                          ref
                              .read(chatStreamProvider.notifier)
                              .sendMessage(text);
                        },
                        onCameraTap: () {
                          // Prompt camera or lab PDF capture
                        },
                        onVoiceTap: () {
                          // Voice intelligence modal
                        },
                        onUrlTap: () {
                          // PubMed URL / DOI reference input
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDesktop,
    String? email,
  ) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00251D).withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF00251D)),
                    tooltip: 'Open Workspace Menu',
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              const SizedBox(width: 4),
              const Text(
                'Personal Intelligence Workspace',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00251D),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Today Screen Quick Switch
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF38675A),
                ),
                icon: const Icon(Icons.wb_sunny_outlined, size: 16),
                label: const Text(
                  'Today Plan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                onPressed: () => context.go('/today'),
              ),
              const SizedBox(width: 8),

              // Control Centre / Profile Avatar Button
              InkWell(
                onTap: () => context.go('/profile'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0EC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00251D).withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF00251D),
                        child: Text(
                          (email != null && email.isNotEmpty)
                              ? email[0].toUpperCase()
                              : 'E',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Control Centre',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00251D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0EC),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00251D).withOpacity(0.1),
              ),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 28,
              color: Color(0xFF00251D),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Continuous Body Intelligence',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00251D),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Explore nutritional calculations, lab biomarkers, research papers, '
              'and personalized habit protocols grounded in your personal baseline state.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF00251D).withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
