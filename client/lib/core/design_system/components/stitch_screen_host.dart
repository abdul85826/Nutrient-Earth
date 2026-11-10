// ==============================================================================
// Nutrient Earth — Exact Stitch Screen Host Widget
// Directly embeds the authentic, pixel-exact Stitch HTML/CSS/JS screens
// with bidirectional JavaScript bridge connecting to Riverpod & Supabase.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';
import '../../../features/onboarding/state/onboarding_journey_state.dart';
import '../../../features/today/state/today_state.dart';
import '../../services/auth_destination_resolver.dart';
import '../../services/auth_service.dart';
import '../../services/profile_repository.dart';
import '../../services/task_repository.dart';
import 'stitch_view_interface.dart';
import 'stitch_view_selector.dart';

class StitchScreenHostWidget extends ConsumerStatefulWidget {
  final int screenIndex;
  final String? returnTo;
  final void Function(String type, Map<String, dynamic> payload)? onAction;

  const StitchScreenHostWidget({
    super.key,
    required this.screenIndex,
    this.returnTo,
    this.onAction,
  });

  @override
  ConsumerState<StitchScreenHostWidget> createState() => _StitchScreenHostWidgetState();
}

class _StitchScreenHostWidgetState extends ConsumerState<StitchScreenHostWidget> {
  late final StitchViewPlatform _platformView;
  bool _isAuthenticating = false;
  String _authLoadingMessage = 'Connecting with Google...';

  @override
  void initState() {
    super.initState();
    _platformView = getPlatformStitchView();
  }

  @visibleForTesting
  Future<void> handleStitchMessageForTesting(Map<String, dynamic> msg) => _handleStitchMessage(msg);

  Future<void> _handleStitchMessage(Map<String, dynamic> msg) async {
    final type = msg['type'] as String? ?? '';
    debugPrint('[StitchScreenHost] Screen ${widget.screenIndex} received: $type => $msg');

    if (widget.onAction != null) {
      widget.onAction!(type, msg);
    }

    final notifier = ref.read(onboardingJourneyProvider.notifier);

    switch (type) {
      case 'NAVIGATE':
        final route = msg['route'] as String?;
        if (route != null && mounted) {
          context.go(route);
        }
        break;

      case 'GOOGLE_SIGN_IN':
        if (_isAuthenticating) {
          debugPrint('[StitchScreenHost] Google sign-in already in progress. Ignoring duplicate.');
          break;
        }

        setState(() {
          _isAuthenticating = true;
          _authLoadingMessage = kIsWeb ? 'Connecting to Google...' : 'Opening Google account chooser...';
        });

        try {
          final authService = ref.read(authServiceProvider);
          final profileRepo = ref.read(profileRepositoryProvider);

          final success = await authService.signInWithGoogle();

          if (kIsWeb) {
            // On web, signInWithOAuth initiates redirect; loading message is displayed until page navigates
            if (mounted) {
              setState(() {
                _authLoadingMessage = 'Redirecting to Google...';
              });
            }
          } else {
            // Native Mobile (Android & iOS)
            if (!success) {
              // User cancelled native account chooser
              if (mounted) {
                setState(() {
                  _isAuthenticating = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google sign-in was cancelled.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF38675A),
                  ),
                );
              }
              return;
            }

            // Successfully authenticated on mobile
            final user = authService.currentUser;
            if (user != null && mounted) {
              setState(() {
                _authLoadingMessage = 'Opening your personal plan...';
              });

              final destination = await AuthDestinationResolver.resolveDestination(
                profileRepository: profileRepo,
                userId: user.id,
                returnTo: widget.returnTo,
              );

              if (mounted) {
                context.go(destination);
              }
            }
          }
        } on AuthException catch (ae) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ae.message)),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Google sign-in failed: $e')),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } finally {
          if (mounted && !kIsWeb) {
            setState(() {
              _isAuthenticating = false;
            });
          }
        }
        break;

      case 'EMAIL_SIGN_IN':
        final email = msg['email'] as String?;
        final captchaToken = msg['captchaToken'] as String?;

        // 1. Validate email structure
        if (email == null || email.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email address.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        final cleanEmail = email.trim().toLowerCase();
        final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
        if (!emailRegex.hasMatch(cleanEmail) || cleanEmail.length > 254) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email format (e.g. name@example.com).'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        // 2. Validate CAPTCHA Token
        if (captchaToken != null && captchaToken.length > 4096) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Security verification token invalid. Please refresh the page.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        if (kIsWeb && (captchaToken == null || captchaToken.trim().isEmpty)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Security verification required. Please complete the verification challenge.'),
                backgroundColor: Color(0xFFBA1A1A),
              ),
            );
          }
          break;
        }

        // 3. Duplicate request guard
        if (_isAuthenticating) {
          debugPrint('[StitchScreenHost] Authentication already in progress. Ignoring duplicate request.');
          break;
        }

        setState(() {
          _isAuthenticating = true;
          _authLoadingMessage = 'Sending secure verification code...';
        });

        try {
          final authService = ref.read(authServiceProvider);
          await authService.signInWithOtp(
            email: cleanEmail,
            captchaToken: captchaToken,
          );
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            final returnTarget = widget.returnTo != null && widget.returnTo!.isNotEmpty
                ? '&returnTo=${Uri.encodeComponent(widget.returnTo!)}'
                : '';
            context.go('/auth/verify-email?email=${Uri.encodeComponent(cleanEmail)}$returnTarget');
          }
        } on AuthException catch (ae) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            final msg = ae.message.toLowerCase();
            final displayError = msg.contains('captcha')
                ? 'Verification check expired or invalid. Please retry the security challenge.'
                : ae.message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(displayError)),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Failed to send sign-in link: $e')),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
          }
        }
        break;

      case 'SAVE_GOALS':
        final rawGoals = msg['goals'];
        if (rawGoals is List) {
          for (final g in rawGoals) {
            notifier.toggleHealthGoal(g.toString());
          }
        }
        final next = msg['nextRoute'] as String? ?? '/onboarding/difficulties';
        if (mounted) context.go(next);
        break;

      case 'SAVE_DIFFICULTIES':
        final rawDiffs = msg['difficulties'];
        if (rawDiffs is List) {
          for (final d in rawDiffs) {
            notifier.toggleDifficulty(d.toString());
          }
        }
        final note = msg['note'] as String?;
        if (note != null && note.isNotEmpty) {
          notifier.setDifficultiesNote(note);
        }
        final next = msg['nextRoute'] as String? ?? '/onboarding/daily-impact';
        if (mounted) context.go(next);
        break;

      case 'SAVE_DAILY_IMPACTS':
        final next = msg['nextRoute'] as String? ?? '/onboarding/food-choices';
        if (mounted) context.go(next);
        break;

      case 'SAVE_FOOD_CHOICES':
        final next = msg['nextRoute'] as String? ?? '/onboarding/review-phase1';
        if (mounted) context.go(next);
        break;

      case 'SAVE_PERSONAL_DETAILS':
        final name = msg['name'] as String? ?? '';
        final age = msg['age'] as int? ?? 25;
        notifier.setPersonalDetails(name: name, age: age);
        final next = msg['nextRoute'] as String? ?? '/onboarding/body-measurements';
        if (mounted) context.go(next);
        break;

      case 'SAVE_MEASUREMENTS':
        final next = msg['nextRoute'] as String? ?? '/onboarding/health-concerns';
        if (mounted) context.go(next);
        break;

      case 'SAVE_CONCERNS':
        final next = msg['nextRoute'] as String? ?? '/onboarding/food-restrictions';
        if (mounted) context.go(next);
        break;

      case 'SAVE_RESTRICTIONS':
        final next = msg['nextRoute'] as String? ?? '/onboarding/eating-routine';
        if (mounted) context.go(next);
        break;

      case 'SAVE_EATING_ROUTINE':
        final routine = msg['routine'] as String?;
        if (routine != null) notifier.setEatingRoutine(routine);
        final next = msg['nextRoute'] as String? ?? '/onboarding/daily-activity';
        if (mounted) context.go(next);
        break;

      case 'SAVE_ACTIVITY_LEVEL':
        final level = msg['level'] as String?;
        if (level != null) notifier.setActivityLevel(level);
        final next = msg['nextRoute'] as String? ?? '/onboarding/sleep-patterns';
        if (mounted) context.go(next);
        break;

      case 'SAVE_SLEEP_QUALITY':
        final quality = msg['quality'] as String?;
        if (quality != null) notifier.setSleepQuality(quality);
        final next = msg['nextRoute'] as String? ?? '/onboarding/knowledge-level';
        if (mounted) context.go(next);
        break;

      case 'SAVE_KNOWLEDGE_LEVEL':
        final level = msg['level'] as String?;
        if (level != null) notifier.setKnowledgeLevel(level);
        final next = msg['nextRoute'] as String? ?? '/onboarding/completion';
        if (mounted) context.go(next);
        break;

      case 'COMPLETE_ONBOARDING':
        try {
          await notifier.completeOnboarding(
            auth: ref.read(authServiceProvider),
            profileRepo: ref.read(profileRepositoryProvider),
            taskRepo: ref.read(taskRepositoryProvider),
          );
        } catch (e) {
          debugPrint('Onboarding completion persistence note: $e');
        }
        if (mounted) context.go('/today');
        break;

      case 'CHAT_PROMPT':
        final text = msg['text'] as String?;
        if (text != null && text.isNotEmpty) {
          ref.read(todayStateProvider.notifier).submitResearch(text);
        }
        break;

      case 'TOGGLE_TASK':
        final rawIndex = msg['index'] ?? msg['taskId'];
        final index = rawIndex is int ? rawIndex : int.tryParse(rawIndex?.toString() ?? '0') ?? 0;
        ref.read(todayStateProvider.notifier).toggleTask(index);
        break;

      default:
        final next = msg['nextRoute'] as String?;
        if (next != null && mounted) {
          context.go(next);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idxStr = widget.screenIndex.toString().padLeft(2, '0');
    final String url;
    if (widget.screenIndex == 3) {
      final siteKey = AppConfig.turnstileSiteKey;
      final query = siteKey.isNotEmpty ? '?sitekey=${Uri.encodeComponent(siteKey)}' : '';
      url = 'stitch/screen_03/$query';
    } else {
      url = 'stitch/screen_$idxStr/';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: _platformView.buildView(
                screenIndex: widget.screenIndex,
                initialUrl: url,
                onMessage: _handleStitchMessage,
              ),
            ),
            if (_isAuthenticating)
              Positioned.fill(
                child: Container(
                  color: const Color(0x99051F20),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF9F4),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF38675A),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _authLoadingMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000A06),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Verifying clinical identity session',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              color: Color(0xFF414845),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
