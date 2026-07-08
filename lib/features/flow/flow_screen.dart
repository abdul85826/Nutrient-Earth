import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/models/app_models.dart';

class FlowScreen extends ConsumerStatefulWidget {
  const FlowScreen({super.key});

  @override
  ConsumerState<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends ConsumerState<FlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(actionProvider);
    final bodyState = actionState.bodyState;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildVerticalFlow(bodyState),
          _buildFloatingHeader(bodyState),
          _buildProgressIndicator(bodyState.actions.length),
        ],
      ),
    );
  }

  Widget _buildVerticalFlow(BodyState state) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (idx) {
        setState(() => _currentPage = idx);
        HapticFeedback.selectionClick();
      },
      itemCount: state.actions.length,
      itemBuilder: (context, index) {
        return _ProtocolSession(
          action: state.actions[index],
          isActive: _currentPage == index,
          isLast: index == state.actions.length - 1,
          onComplete: () {
            if (index < state.actions.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutExpo,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildFloatingHeader(BodyState state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            color: Colors.black.withValues(alpha: 0.4),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.neonGreen, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'ADAPTIVE FLOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.energyScore.round()}% ENERGY',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int total) {
    return Positioned(
      right: 12,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (index) {
            final active = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4,
              height: active ? 32 : 8,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.neonGreen : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ProtocolSession extends StatelessWidget {
  final DailyAction action;
  final bool isActive;
  final bool isLast;
  final VoidCallback onComplete;

  const _ProtocolSession({
    required this.action,
    required this.isActive,
    required this.isLast,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = action.type == 'activity'
        ? AppColors.neonGreen
        : (action.type == 'hydration'
              ? Colors.cyanAccent
              : AppColors.warmOrange);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, color.withValues(alpha: 0.1), Colors.black],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Biological Icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: isActive ? 1.0 : 0.8),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.1),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          action.icon,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Instruction
              Text(
                action.title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                action.instruction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                action.benefit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Action Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  onComplete();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'INITIATE PROTOCOL',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!isLast)
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white24,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
