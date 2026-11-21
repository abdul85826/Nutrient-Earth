import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/learn_repository.dart';
import '../state/today_state.dart';
import 'widgets/header_bar.dart';
import 'widgets/dynamic_greeting_card.dart';
import 'widgets/telemetry_strip.dart';
import 'widgets/research_search_bar.dart';
import 'widgets/daily_plan_section.dart';
import 'widgets/learn_today_section.dart';
import 'widgets/feedback_banner.dart';
import 'widgets/today_drawer.dart';
import 'widgets/research_result_modal.dart';
import 'widgets/learn_detail_modal.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(todayStateProvider.notifier).refreshTelemetry();
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openProfile() {
    final state = ref.read(todayStateProvider);
    final name = state.userProfile?.displayName ?? 'Sarah Jenkins';
    final goal = state.userProfile?.primaryGoal ?? 'Endurance Recovery';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile: $name • Active Goal: $goal'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleResearchSubmit(String query) async {
    final notifier = ref.read(todayStateProvider.notifier);
    await notifier.submitResearch(query);

    if (!mounted) return;
    final currentState = ref.read(todayStateProvider);
    if (currentState.activeAnswer != null) {
      ResearchResultModal.show(context, currentState.activeAnswer!);
    } else if (currentState.researchError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Research error: ${currentState.researchError}'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  void _handleCameraTap() {
    _showAttachmentDialog(
      title: 'Scan Meal or Food Label',
      icon: Icons.camera_alt_rounded,
      message: 'Take a photo or choose an image from gallery to analyze nutrition with research evidence.',
      actionText: 'Select Image & Analyze',
      onConfirm: () {
        _handleResearchSubmit('Analyze nutritional composition of this meal');
      },
    );
  }

  void _handleVoiceTap() {
    _showAttachmentDialog(
      title: 'Voice Research Input',
      icon: Icons.mic_rounded,
      message: 'Tap start to record your scientific inquiry. Speech-to-text will transcribe and verify evidence.',
      actionText: 'Start Recording',
      onConfirm: () {
        _handleResearchSubmit('How does dietary magnesium glycinate compare for sleep quality?');
      },
    );
  }

  void _showAttachmentDialog({
    required String title,
    required IconData icon,
    required String message,
    required String actionText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NETokens.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        icon: Icon(icon, color: NETokens.emerald, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13.5, color: NETokens.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: NETokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.deepGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _handleViewEvidence(DailyPlanTask task) {
    _handleResearchSubmit('Evidence basis for ${task.title}: ${task.note}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todayStateProvider);
    final notifier = ref.read(todayStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: NETokens.background,
      drawer: TodayDrawer(
        onNewChat: () {
          _handleResearchSubmit('Explore personalized nutritional interventions');
        },
        onSelectHistory: (query) {
          _handleResearchSubmit(query);
        },
        onProfileTap: _openProfile,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: RefreshIndicator(
              color: NETokens.emerald,
              onRefresh: () async {
                await notifier.refreshTelemetry();
                await notifier.loadDailyTasks();
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Bar with Menu, Monogram, and Profile
                    HeaderBar(
                      onMenuPressed: _openDrawer,
                      onProfilePressed: _openProfile,
                      onLogoPressed: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // 2. Dynamic Personalized Greeting Card
                    DynamicGreetingCard(
                      diurnal: state.diurnal,
                      onAvatarTap: _openProfile,
                    ),
                    const SizedBox(height: 12),

                    // 3. Environmental & Physiological Telemetry Strip
                    TelemetryStrip(
                      telemetry: state.telemetry,
                      onRefresh: () => notifier.refreshTelemetry(),
                    ),
                    const SizedBox(height: 16),

                    // 4. Botanical Research Search Bar & Suggestions
                    ResearchSearchBar(
                      isLoading: state.isResearchLoading,
                      onSubmit: _handleResearchSubmit,
                      onCameraTap: _handleCameraTap,
                      onVoiceTap: _handleVoiceTap,
                    ),
                    const SizedBox(height: 18),

                    // 5. Daily Plan Interactive Checklist Section
                    DailyPlanSection(
                      tasks: state.tasks,
                      counterLabel: state.counterLabel,
                      onToggleTask: (index) {
                        notifier.toggleTask(index);
                      },
                      onWhyRoutineTap: () {
                        _handleResearchSubmit('Why this daily routine fits my endurance recovery goals');
                      },
                      onViewEvidenceTap: _handleViewEvidence,
                    ),
                    const SizedBox(height: 18),

                    // 6. Learn for Today Media Grid
                    LearnTodaySection(
                      items: LearnRepository.featuredItems,
                      onItemTap: (item) {
                        LearnDetailModal.show(context, item);
                      },
                      onSeeAllTap: () {
                        _showAllLearnModal(context);
                      },
                    ),
                    const SizedBox(height: 18),

                    // 7. Ambient User Feedback Footer
                    FeedbackBanner(
                      isSubmitted: state.feedbackSubmitted,
                      onSubmit: (feedback) {
                        notifier.submitFeedback(feedback);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feedback received. Thank you!'),
                            backgroundColor: NETokens.emerald,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAllLearnModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final articles = LearnRepository.getArticles();
        final videos = LearnRepository.getVideos();

        return Container(
          decoration: const BoxDecoration(
            color: NETokens.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: NETokens.borderDefault,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TabBar(
                    labelColor: NETokens.primary,
                    unselectedLabelColor: NETokens.textMuted,
                    indicatorColor: NETokens.emerald,
                    tabs: [
                      Tab(text: 'Articles (10)'),
                      Tab(text: 'Videos (10)'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final item = articles[index];
                            return ListTile(
                              dense: true,
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              subtitle: Text(item.description, style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                              onTap: () {
                                Navigator.pop(context);
                                LearnDetailModal.show(context, item);
                              },
                            );
                          },
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final item = videos[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.play_circle_fill_rounded, color: NETokens.emerald),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              subtitle: Text('${item.duration ?? ""} • ${item.description}', style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                              onTap: () {
                                Navigator.pop(context);
                                LearnDetailModal.show(context, item);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
