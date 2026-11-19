// ==============================================================================
// Nutrient Earth — Intelligence Workspace Persistent Sidebar
// Responsive, accessible left-sidebar and mobile drawer for:
// - New Conversation initiation
// - Universal Search (Ctrl+K)
// - Conversation History (Pinned, Recent, Actions)
// - Research Projects & Workspaces
// - Saved Intelligence & Reports
// - Connected Intelligence Telemetry Links
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/workspace/workspace_models.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/workspace/workspace_repository.dart';
import '../../state/chat_stream_notifier.dart';

class IntelligenceWorkspaceSidebar extends ConsumerStatefulWidget {
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;
  final bool isCollapsed;

  const IntelligenceWorkspaceSidebar({
    super.key,
    this.isDrawer = false,
    this.onToggleCollapse,
    this.isCollapsed = false,
  });

  @override
  ConsumerState<IntelligenceWorkspaceSidebar> createState() =>
      _IntelligenceWorkspaceSidebarState();
}

class _IntelligenceWorkspaceSidebarState
    extends ConsumerState<IntelligenceWorkspaceSidebar> {
  int _selectedWorkspaceTab = 0; // 0: Chats, 1: Projects, 2: Saved
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<UniversalSearchResult> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    final auth = ref.read(authServiceProvider);
    final userId = auth.currentUser?.id ?? 'default_user';
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    final repo = ref.read(workspaceRepositoryProvider);
    final results = await repo.searchEverything(userId: userId, query: query);
    if (mounted) {
      setState(() => _searchResults = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final user = auth.currentUser;
    final userId = user?.id ?? 'default_user';
    final chatState = ref.watch(chatStreamProvider);

    final conversationsAsync = ref.watch(userConversationsProvider(userId));
    final projectsAsync = ref.watch(userProjectsProvider(userId));
    final savedAsync = ref.watch(userSavedItemsProvider(userId));

    final theme = Theme.of(context);
    final isCompact = widget.isCollapsed && !widget.isDrawer;

    return Container(
      width: isCompact ? 72 : 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0), // Refined warm cream
        border: Border(
          right: BorderSide(
            color: const Color(0xFF00251D).withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Top Header & Brand Anchor
            _buildHeader(isCompact),

            // 2. Action Controls: New Conversation & Search
            if (!isCompact) ...[
              _buildPrimaryActions(userId),
              const SizedBox(height: 8),
              _buildWorkspaceTabBar(),
            ] else ...[
              _buildCompactActions(),
            ],

            const Divider(height: 16, color: Color(0x1400251D)),

            // 3. Main Workspace Content Area
            Expanded(
              child: _isSearching && !isCompact
                  ? _buildSearchResultsList()
                  : isCompact
                      ? _buildCompactIconList()
                      : _buildSelectedTabContent(
                          conversationsAsync,
                          projectsAsync,
                          savedAsync,
                          chatState.activeConversationId,
                          userId,
                        ),
            ),

            const Divider(height: 16, color: Color(0x1400251D)),

            // 4. Connected Intelligence Quick Links
            if (!isCompact) _buildConnectedIntelligenceSection(),

            // 5. User Account & Control Centre Anchor
            _buildAccountFooter(user?.email, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment:
            isCompact ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF00251D),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'NE',
                    style: TextStyle(
                      color: Color(0xFFB8EADA),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 10),
                const Text(
                  'Nutrient Earth',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00251D),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
          if (!isCompact && widget.onToggleCollapse != null)
            IconButton(
              icon: const Icon(Icons.menu_open, size: 20, color: Color(0xFF38675A)),
              tooltip: 'Collapse sidebar',
              onPressed: widget.onToggleCollapse,
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // New Conversation Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00251D),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'New Conversation',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            onPressed: () {
              ref.read(chatStreamProvider.notifier).startNewConversation();
              if (widget.isDrawer) Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),

          // Universal Search Field
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x1F00251D)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: const TextStyle(fontSize: 13, color: Color(0xFF00251D)),
              decoration: InputDecoration(
                hintText: 'Search workspace (Ctrl+K)...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF00251D).withOpacity(0.45),
                ),
                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF38675A)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActions() {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF00251D), size: 28),
          tooltip: 'New Conversation',
          onPressed: () {
            ref.read(chatStreamProvider.notifier).startNewConversation();
          },
        ),
        if (widget.onToggleCollapse != null)
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 22, color: Color(0xFF38675A)),
            tooltip: 'Expand sidebar',
            onPressed: widget.onToggleCollapse,
          ),
      ],
    );
  }

  Widget _buildWorkspaceTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 34,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0EC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildTabItem(0, 'Chats', Icons.chat_bubble_outline),
            _buildTabItem(1, 'Projects', Icons.folder_outlined),
            _buildTabItem(2, 'Saved', Icons.bookmark_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedWorkspaceTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedWorkspaceTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? const Color(0xFF00251D) : const Color(0xFF38675A),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF00251D) : const Color(0xFF38675A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(
    AsyncValue<List<WorkspaceConversation>> convsAsync,
    AsyncValue<List<WorkspaceProject>> projectsAsync,
    AsyncValue<List<WorkspaceSavedItem>> savedAsync,
    String activeId,
    String userId,
  ) {
    switch (_selectedWorkspaceTab) {
      case 0:
        return convsAsync.when(
          data: (items) => _buildConversationsList(items, activeId, userId),
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(fontSize: 11))),
        );
      case 1:
        return projectsAsync.when(
          data: (projects) => _buildProjectsList(projects, userId),
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(fontSize: 11))),
        );
      case 2:
        return savedAsync.when(
          data: (saved) => _buildSavedItemsList(saved, userId),
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(fontSize: 11))),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConversationsList(
    List<WorkspaceConversation> items,
    String activeId,
    String userId,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No conversations yet.\nStart a dialogue to explore your body intelligence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF00251D).withOpacity(0.5),
              height: 1.4,
            ),
          ),
        ),
      );
    }

    final pinned = items.where((c) => c.isPinned).toList();
    final recents = items.where((c) => !c.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      children: [
        if (pinned.isNotEmpty) ...[
          _buildSectionHeader('PINNED'),
          ...pinned.map((c) => _buildConversationTile(c, c.id == activeId, userId)),
          const SizedBox(height: 8),
        ],
        _buildSectionHeader('RECENT CONVERSATIONS'),
        ...recents.map((c) => _buildConversationTile(c, c.id == activeId, userId)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B8E83),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildConversationTile(
    WorkspaceConversation conv,
    bool isActive,
    String userId,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEAF0EC) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Icon(
          conv.isPinned ? Icons.push_pin : Icons.chat_bubble_outline,
          size: 15,
          color: isActive ? const Color(0xFF00251D) : const Color(0xFF38675A),
        ),
        title: Text(
          conv.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF00251D),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, size: 16, color: Color(0xFF6B8E83)),
          onSelected: (action) async {
            final repo = ref.read(workspaceRepositoryProvider);
            if (action == 'pin') {
              await repo.updateConversation(
                conversationId: conv.id,
                isPinned: !conv.isPinned,
              );
              ref.refresh(userConversationsProvider(userId));
            } else if (action == 'archive') {
              await repo.updateConversation(
                conversationId: conv.id,
                isArchived: true,
              );
              ref.refresh(userConversationsProvider(userId));
            } else if (action == 'delete') {
              await repo.deleteConversation(conv.id);
              ref.refresh(userConversationsProvider(userId));
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: Text(conv.isPinned ? 'Unpin' : 'Pin to top'),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Text('Archive'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: () {
          ref
              .read(chatStreamNotifierProvider.notifier)
              .loadExistingConversation(conv.id);
          if (widget.isDrawer) Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildProjectsList(List<WorkspaceProject> projects, String userId) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('RESEARCH PROJECTS'),
              IconButton(
                icon: const Icon(Icons.add, size: 18, color: Color(0xFF00251D)),
                tooltip: 'Create Project',
                onPressed: () => _promptCreateProject(userId),
              ),
            ],
          ),
        ),
        if (projects.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No research projects yet.\nCreate workspaces to organize your investigations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF00251D).withOpacity(0.5),
                ),
              ),
            ),
          ),
        ...projects.map((p) => ListTile(
              dense: true,
              leading: Icon(Icons.folder, color: Color(int.parse(p.colorHex.replaceFirst('#', '0xFF'))), size: 18),
              title: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: p.description != null ? Text(p.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)) : null,
              onTap: () {
                // Filter workspace to this project
              },
            )),
      ],
    );
  }

  Widget _buildSavedItemsList(List<WorkspaceSavedItem> saved, String userId) {
    if (saved.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No saved intelligence yet.\nBookmark key insights, reports, and calculations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF00251D).withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      children: [
        _buildSectionHeader('SAVED INTELLIGENCE'),
        ...saved.map((s) => ListTile(
              dense: true,
              leading: const Icon(Icons.bookmark, size: 16, color: Color(0xFF38675A)),
              title: Text(s.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(s.contentSnippet, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                onPressed: () async {
                  await ref.read(workspaceRepositoryProvider).deleteSavedItem(s.id);
                  ref.refresh(userSavedItemsProvider(userId));
                },
              ),
            )),
      ],
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No matching intelligence found.',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF00251D).withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final res = _searchResults[index];
        return ListTile(
          dense: true,
          leading: Icon(
            res.sourceType == SearchResultSourceType.conversation
                ? Icons.chat_bubble
                : res.sourceType == SearchResultSourceType.project
                    ? Icons.folder
                    : Icons.bookmark,
            size: 16,
            color: const Color(0xFF38675A),
          ),
          title: Text(res.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: Text(res.snippet, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
          onTap: () {
            if (res.sourceType == SearchResultSourceType.conversation) {
              ref
                  .read(chatStreamNotifierProvider.notifier)
                  .loadExistingConversation(res.entityId);
              if (widget.isDrawer) Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  Widget _buildCompactIconList() {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF38675A)),
          tooltip: 'Conversations',
          onPressed: widget.onToggleCollapse,
        ),
        IconButton(
          icon: const Icon(Icons.folder_outlined, size: 20, color: Color(0xFF38675A)),
          tooltip: 'Projects',
          onPressed: widget.onToggleCollapse,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_outline, size: 20, color: Color(0xFF38675A)),
          tooltip: 'Saved Items',
          onPressed: widget.onToggleCollapse,
        ),
      ],
    );
  }

  Widget _buildConnectedIntelligenceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CONNECTED INTELLIGENCE'),
          const SizedBox(height: 4),
          _buildTelemetryPill(
            icon: Icons.devices_other,
            label: 'My Connected Devices',
            route: '/profile?tab=devices',
          ),
          _buildTelemetryPill(
            icon: Icons.monitor_heart_outlined,
            label: 'Health Data (HealthKit / Connect)',
            route: '/profile?tab=health',
          ),
          _buildTelemetryPill(
            icon: Icons.air_outlined,
            label: 'Environment Monitoring (Open-Meteo)',
            route: '/today',
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryPill({
    required IconData icon,
    required String label,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF38675A)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF00251D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountFooter(String? email, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 14,
        vertical: 10,
      ),
      child: isCompact
          ? IconButton(
              icon: const Icon(Icons.person_outline, size: 22, color: Color(0xFF00251D)),
              tooltip: 'Account & Settings',
              onPressed: () => context.go('/profile'),
            )
          : InkWell(
              onTap: () => context.go('/profile'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF00251D),
                      child: Text(
                        (email != null && email.isNotEmpty)
                            ? email[0].toUpperCase()
                            : 'E',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Control Centre',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00251D),
                            ),
                          ),
                          Text(
                            email ?? 'Signed in',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF38675A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF38675A)),
                  ],
                ),
              ),
            ),
    );
  }

  void _promptCreateProject(String userId) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Research Project', style: TextStyle(fontFamily: 'serif')),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Metabolic Health & Fiber Protocol',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00251D)),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await ref.read(workspaceRepositoryProvider).createProject(
                      userId: userId,
                      name: nameController.text.trim(),
                    );
                ref.refresh(userProjectsProvider(userId));
                if (mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
