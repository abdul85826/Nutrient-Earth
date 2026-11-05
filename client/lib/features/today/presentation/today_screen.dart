import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/input_gateway/input_classification_gateway.dart';
import '../../../../core/domain/input_gateway/universal_input_descriptor.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/learn_repository.dart';
import '../../../../core/services/profile_repository.dart';
import '../state/today_state.dart';
import 'widgets/header_bar.dart';
import 'widgets/dynamic_greeting_card.dart';
import 'widgets/telemetry_strip.dart';
import 'widgets/research_search_bar.dart';
import 'widgets/daily_plan_section.dart';
import 'widgets/learn_today_section.dart';
import 'widgets/feedback_banner.dart';
import 'widgets/today_drawer.dart';
import 'widgets/learn_detail_modal.dart';
import 'widgets/privacy_data_modal.dart';
import 'widgets/universal_reference_answer_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  void _openProfile() async {
    final profile = await ref.read(profileRepositoryProvider).getCurrentUserProfile();
    if (!mounted) return;
    if (profile != null) {
      final goal = profile.primaryGoals.isNotEmpty ? profile.primaryGoals.first : 'Active Health';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile: ${profile.displayName} • Active Goal: $goal'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      context.push('/onboarding');
    }
  }


  void _handleResearchSubmit(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final currentState = ref.read(todayStateProvider);
    if (currentState.isResearchLoading) return; // Prevent duplicate submissions

    final notifier = ref.read(todayStateProvider.notifier);
    await notifier.submitResearch(clean);

    if (!mounted) return;
    final updatedState = ref.read(todayStateProvider);
    if (updatedState.activeAnswer != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => UniversalReferenceAnswerCard.fromResearchAnswer(
            answer: updatedState.activeAnswer!,
            onBack: () => Navigator.of(ctx).pop(),
          ),
        ),
      );
    } else if (updatedState.researchError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Research error: ${updatedState.researchError}'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  void _handleCameraTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: NETokens.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NETokens.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Multimodal Input & Visual Scanner',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: NETokens.primary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Capture meal photos, upload gallery images, verify PDF documents, or scan product barcodes.',
                style: TextStyle(fontSize: 12.5, color: NETokens.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2E7D32)),
                title: const Text('Live Device Camera (Take Photo)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: const Text('Open physical camera, snap label or food for instant analysis', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _handleLiveCameraCapture();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: NETokens.forest),
                title: const Text('Choose from Photo Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Select an existing photo of a meal, supplement, or product', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _handleGalleryPick();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: NETokens.darkEvergreen),
                title: const Text('Upload Scientific PDF Document', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Extracts key clinical findings and links citations', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _handlePdfDocumentUpload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded, color: NETokens.botanicalTeal),
                title: const Text('Scan Product Barcode (UPC / EAN)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Identifies certified ingredients & checks goal alignment', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _showBarcodeInputDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLiveCameraCapture() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo == null || !mounted) return;

      final bytes = await photo.readAsBytes();
      final result = const InputClassificationGateway().processFile(
        filePath: photo.path,
        fileBytes: bytes,
        source: InputSourceType.cameraCapture,
        userPrompt: 'Analyze photo captured by device camera',
      );

      if (result.isValid && result.validatedDescriptor != null) {
        _handleDescriptorSubmit(result.validatedDescriptor!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Invalid image captured.'),
            backgroundColor: NETokens.error,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: ${e.message ?? 'Permission denied.'}'),
          backgroundColor: NETokens.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  Future<void> _handleGalleryPick() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo == null || !mounted) return;

      final bytes = await photo.readAsBytes();
      final result = const InputClassificationGateway().processFile(
        filePath: photo.path,
        fileBytes: bytes,
        source: InputSourceType.galleryUpload,
        userPrompt: 'Analyze meal or product image from gallery',
      );

      if (result.isValid && result.validatedDescriptor != null) {
        _handleDescriptorSubmit(result.validatedDescriptor!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Invalid image selected.'),
            backgroundColor: NETokens.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  Future<void> _handlePdfDocumentUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;

      final file = result.files.first;
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        throw Exception('Could not read document contents.');
      }

      final validation = const InputClassificationGateway().processFile(
        filePath: file.name,
        fileBytes: bytes,
        source: InputSourceType.filePicker,
        userPrompt: 'Extract and analyze clinical evidence from ${file.name}',
      );

      if (validation.isValid && validation.validatedDescriptor != null) {
        _handleDescriptorSubmit(validation.validatedDescriptor!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.errorMessage ?? 'Invalid document selected.'),
            backgroundColor: NETokens.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload document: $e'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  Future<void> _handleAudioUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        withData: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;

      final file = result.files.first;
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        throw Exception('Could not read audio file.');
      }

      final validation = const InputClassificationGateway().processFile(
        filePath: file.name,
        fileBytes: bytes,
        source: InputSourceType.audioFile,
        userPrompt: 'Audio dictation: Spoken nutritional inquiry',
      );

      if (validation.isValid && validation.validatedDescriptor != null) {
        _handleDescriptorSubmit(validation.validatedDescriptor!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.errorMessage ?? 'Invalid audio file.'),
            backgroundColor: NETokens.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load audio: $e'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  void _showBarcodeInputDialog() {
    final controller = TextEditingController(text: '012345678905');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NETokens.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        title: const Text('Enter Product Barcode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a 12-digit UPC-A or 13-digit EAN barcode to retrieve verified ingredients and calculate goal synergy.',
              style: TextStyle(fontSize: 12.5, color: NETokens.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 012345678905',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: NETokens.borderDefault),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: NETokens.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NETokens.darkEvergreen, foregroundColor: Colors.white),
            onPressed: () {
              final barcode = controller.text.trim();
              Navigator.pop(context);
              if (barcode.isNotEmpty) {
                final descriptor = InputClassificationGateway.classifyRawInput(
                  rawInput: barcode,
                  sourceType: InputSourceType.barcodeScanner,
                );
                _handleDescriptorSubmit(descriptor);
              }
            },
            child: const Text('Lookup & Verify'),
          ),
        ],
      ),
    );
  }

  void _handleVoiceTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: NETokens.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NETokens.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Voice & Audio Inquiry',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: NETokens.primary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Speak or upload audio recordings for transcription and evidence synthesis.',
                style: TextStyle(fontSize: 12.5, color: NETokens.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.mic_rounded, color: Color(0xFF2E7D32)),
                title: const Text('Spoken Question / Voice Inquiry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: const Text('Transcribes and checks clinical trials for your query', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _handleResearchSubmit('How does dietary magnesium glycinate compare for sleep quality?');
                },
              ),
              ListTile(
                leading: const Icon(Icons.audio_file_rounded, color: NETokens.emerald),
                title: const Text('Upload Audio File (MP3, WAV, M4A, OGG)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                subtitle: const Text('Select a voice memo or audio file from device storage', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _handleAudioUpload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUrlTap() {
    final controller = TextEditingController(text: 'https://pubmed.ncbi.nlm.nih.gov/11794633/');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: NETokens.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NETokens.borderDefault,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Analyze URL with Scientific Evidence',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: NETokens.primary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Paste a PubMed publication link, DOI identifier, YouTube video, or Instagram link to verify claims.',
                  style: TextStyle(fontSize: 12.5, color: NETokens.textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.link_rounded, color: NETokens.emerald, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: NETokens.borderDefault),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NETokens.darkEvergreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
                    ),
                    onPressed: () {
                      final url = controller.text.trim();
                      final validation = InputClassificationGateway.validateUrl(url);
                      if (!validation.isValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(validation.errorMessage ?? 'Invalid URL'),
                            backgroundColor: NETokens.error,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      final descriptor = InputClassificationGateway.classifyRawInput(
                        rawInput: url,
                        sourceType: InputSourceType.clipboardUrl,
                      );
                      _handleDescriptorSubmit(descriptor);
                    },
                    child: const Text('Verify & Analyze URL', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDescriptorSubmit(UniversalInputDescriptor descriptor) async {
    final notifier = ref.read(todayStateProvider.notifier);
    await notifier.submitUniversalInquiry(descriptor);

    if (!mounted) return;
    final updatedState = ref.read(todayStateProvider);
    if (updatedState.activeAnswer != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => UniversalReferenceAnswerCard.fromResearchAnswer(
            answer: updatedState.activeAnswer!,
            onBack: () => Navigator.of(ctx).pop(),
          ),
        ),
      );
    } else if (updatedState.researchError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Research error: ${updatedState.researchError}'),
          backgroundColor: NETokens.error,
        ),
      );
    }
  }

  void _openPrivacyDataControls() {
    PrivacyDataModal.show(context);
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todayStateProvider);
    final notifier = ref.read(todayStateProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: NETokens.background,
      drawer: TodayDrawer(
        profileName: state.userProfile?.displayName,
        profileGoal: state.userProfile?.primaryGoals.isNotEmpty == true
            ? state.userProfile!.primaryGoals.first
            : null,
        onNewChat: () {
          ref.read(todayStateProvider.notifier).clearActiveAnswer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ready for a new inquiry. Enter your question in the research bar.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onSelectHistory: (query) {
          _handleResearchSubmit(query);
        },
        onProfileTap: _openProfile,
        onPrivacyTap: _openPrivacyDataControls,
        isAuthenticated: ref.watch(isAuthenticatedProvider),
        onSignOut: () async {
          await ref.read(authServiceProvider).signOut();
          if (mounted) {
            context.go('/welcome');
          }
        },
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Bar (Drawer Menu, Logo, Profile)
                  HeaderBar(
                    onMenuPressed: _openDrawer,
                    onProfilePressed: _openProfile,
                  ),
                  const SizedBox(height: 14),

                  // 2. Dynamic Greeting Card with Diurnal Botanical Illustration
                  DynamicGreetingCard(
                    diurnal: state.diurnal,
                    activeGoal: state.userProfile?.primaryGoals.isNotEmpty == true
                        ? state.userProfile!.primaryGoals.first
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // 3. Live Environment Telemetry Strip (Time, AQI, Weather, Streak)
                  TelemetryStrip(
                    telemetry: state.telemetry,
                    onRefresh: notifier.refreshTelemetry,
                  ),
                  const SizedBox(height: 20),

                  // 4. Research Search & Multimodal Input Bar
                  ResearchSearchBar(
                    isLoading: state.isResearchLoading,
                    onSubmit: _handleResearchSubmit,
                    onCameraTap: _handleCameraTap,
                    onVoiceTap: _handleVoiceTap,
                    onUrlTap: _handleUrlTap,
                  ),
                  const SizedBox(height: 22),

                  // 5. Your Daily Plan Section (Interactive Checklist)
                  DailyPlanSection(
                    tasks: state.tasks,
                    counterLabel: state.counterLabel,
                    goalLabel: state.userProfile?.primaryGoals.isNotEmpty == true
                        ? state.userProfile!.primaryGoals.first
                        : null,
                    onToggleTask: notifier.toggleTask,
                    onWhyRoutineTap: state.tasks.isEmpty
                        ? null
                        : () {
                            final goal = (state.userProfile?.primaryGoals.isNotEmpty == true)
                                ? state.userProfile!.primaryGoals.first
                                : 'current wellness';
                            _handleResearchSubmit('Why does this routine fit my $goal goals?');
                          },
                  ),
                  const SizedBox(height: 20),

                  // 6. Learn for Today (Media Grid with Video & Article)
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
