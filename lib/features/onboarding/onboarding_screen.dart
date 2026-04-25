import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';



class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Data
  int _age = 25;
  double _weight = 70.0;
  String _goal = 'Longevity';
  final List<String> _goals = ['Longevity', 'Fat Loss', 'Muscle Gain', 'Mental Clarity', 'Energy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildAgeStep(),
                      _buildWeightStep(),
                      _buildGoalStep(),
                      _buildFinalStep(),
                    ],
                  ),
                ),
                _buildNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.darkGradient,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentPage ? AppColors.nutrientGreen : Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAgeStep() {
    return _buildStepLayout(
      title: 'How many years have\nyou been evolving?',
      subtitle: 'Age allows us to calibrate your metabolic baseline.',
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_age',
              style: const TextStyle(fontSize: 120, fontWeight: FontWeight.w900, color: AppColors.nutrientGreen, letterSpacing: -5),
            ),
            const Text('YEARS OLD', style: TextStyle(color: Colors.white38, letterSpacing: 4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.nutrientGreen,
                inactiveTrackColor: Colors.white10,
                thumbColor: Colors.white,
                overlayColor: AppColors.nutrientGreen.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _age.toDouble(),
                min: 18,
                max: 100,
                onChanged: (val) => setState(() => _age = val.toInt()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightStep() {
    return _buildStepLayout(
      title: 'What is your current\nphysical mass?',
      subtitle: 'Weight is a key variable in nutrient absorption math.',
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weight.toStringAsFixed(1),
              style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w900, color: AppColors.nutrientGreen, letterSpacing: -2),
            ),
            const Text('KILOGRAMS', style: TextStyle(color: Colors.white38, letterSpacing: 4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.nutrientGreen,
                inactiveTrackColor: Colors.white10,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: _weight,
                min: 40,
                max: 150,
                onChanged: (val) => setState(() => _weight = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStep() {
    return _buildStepLayout(
      title: 'Select your primary\nevolution target.',
      subtitle: 'We prioritize insights based on your core objective.',
      content: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final isSelected = _goal == _goals[index];
          return GestureDetector(
            onTap: () => setState(() => _goal = _goals[index]),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.nutrientGreen : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
              ),
              child: Row(
                children: [
                  Text(
                    _goals[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.black),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinalStep() {
    return _buildStepLayout(
      title: 'Calibration Complete.',
      subtitle: 'Your biological profile has been generated. The engine is ready.',
      content: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.nutrientGreen, width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5),
            ],
          ),
          child: const Center(
            child: Icon(Icons.verified_user_rounded, color: AppColors.nutrientGreen, size: 80),
          ),
        ),
      ),
    );
  }

  Widget _buildStepLayout({required String title, required String subtitle, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(title, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32, height: 1.1)),
          const SizedBox(height: 16),
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
          const SizedBox(height: 40),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white24),
            )
          else
            const SizedBox(width: 48),
          _currentPage < 3
              ? _buildNavButton('NEXT', () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut))
              : _buildNavButton('FINISH', () {
                  final notifier = ref.read(userProgressProvider.notifier);
                  notifier.updateAge(_age);
                  notifier.updateWeight(_weight);
                  
                  // Map the goal to a problem area
                  if (_goal == 'Energy') notifier.updateProblemArea(ProblemArea.energy);
                  if (_goal == 'Fat Loss') notifier.updateProblemArea(ProblemArea.weight);
                  if (_goal == 'Mental Clarity') notifier.updateProblemArea(ProblemArea.stress);
                  
                  notifier.setOnboardingComplete(true);
                  context.go('/');
                }),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }
}
