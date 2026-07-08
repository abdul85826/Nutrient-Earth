import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import './providers/onboarding_provider.dart';
import '../../core/lifecycle/app_lifecycle_notifier.dart';
import '../../core/lifecycle/app_lifecycle_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final int step;
  const OnboardingScreen({super.key, this.step = 0});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  late int _currentStep;
  static const int _totalSteps = 4;

  // Controllers for TextField inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  final TextEditingController _sleepTimeController = TextEditingController();
  final TextEditingController _wakeTimeController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();

  final TextEditingController _mealTimingController = TextEditingController();
  final TextEditingController _supplementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStep = widget.step;
    _pageController = PageController(initialPage: _currentStep);
    
    Future.microtask(() async {
      final notifier = ref.read(onboardingProvider.notifier);
      await notifier.loadDraft();
      
      // Initialize text controllers from loaded draft state
      final state = ref.read(onboardingProvider);
      _nameController.text = state.name;
      _countryController.text = state.country;
      _cityController.text = state.city;
      _occupationController.text = state.occupation;

      _sleepTimeController.text = state.sleepTime;
      _wakeTimeController.text = state.wakeTime;
      _exerciseController.text = state.exercise;

      _mealTimingController.text = state.mealTiming;
    });
  }

  @override
  void didUpdateWidget(OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step != _currentStep) {
      setState(() => _currentStep = widget.step);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    _sleepTimeController.dispose();
    _wakeTimeController.dispose();
    _exerciseController.dispose();
    _mealTimingController.dispose();
    _supplementController.dispose();
    super.dispose();
  }

  void _onNext() async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(onboardingProvider.notifier);
    
    if (_currentStep < _totalSteps - 1) {
      final nextStep = _currentStep + 1;
      notifier.setStep(nextStep);
      _navigateToStep(nextStep);
    } else {
      await notifier.saveDraft();
      _completeOnboarding();
    }
  }

  void _navigateToStep(int step) {
    String path = '/onboarding';
    switch (step) {
      case 0: path = '/onboarding/identity'; break;
      case 1: path = '/onboarding/lifestyle'; break;
      case 2: path = '/onboarding/food'; break;
      case 3: path = '/onboarding/risk'; break;
    }
    context.go(path);
  }

  void _completeOnboarding() async {
    final notifier = ref.read(onboardingProvider.notifier);
    final lifecycle = ref.read(appLifecycleProvider.notifier);
    
    // Finalize profile data in Supabase & Isar
    await notifier.finalizeOnboarding();
    
    // Mark as completed in lifecycle
    await lifecycle.completeStep(OnboardingStep.environmentSync); // Marks profile as complete in notifier logic
    
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NEColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopProgress(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildIdentityStep(),
                  _buildLifestyleStep(),
                  _buildFoodStep(),
                  _buildRiskStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                IconButton(
                  onPressed: () => _navigateToStep(_currentStep - 1),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                )
              else
                const SizedBox(width: 40),
              
              Text(
                '${_currentStep + 1} / $_totalSteps',
                style: const TextStyle(
                  color: NEColors.accent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: NEColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 4,
                width: MediaQuery.of(context).size.width * ((_currentStep + 1) / _totalSteps),
                decoration: BoxDecoration(
                  gradient: NEColors.morningGradient,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: NEColors.accent.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STEP 1: HEALTH IDENTITY ──────────────────────────────────────────────
  Widget _buildIdentityStep() {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final goals = [
      'Longevity', 'Performance', 'Mental Clarity', 
      'Recovery', 'Metabolic Health', 'Biological Resilience'
    ];

    return _StepLayout(
      title: 'Health Identity',
      subtitle: 'Create your fundamental biological record. Height and Weight are required to calibrate target hydration thresholds (ml/kg) and calculate insulin sensitivity.',
      onContinue: () {
        if (_nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your name.')),
          );
          return;
        }
        notifier.updateStep2(
          name: _nameController.text.trim(),
          country: _countryController.text.trim(),
          city: _cityController.text.trim(),
          occupation: _occupationController.text.trim(),
        );
        _onNext();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Your Name', _nameController, hint: 'e.g., Alex'),
          const SizedBox(height: 16),
          _buildMetricRow('Age', '${state.age}', 10, 100, (val) => notifier.updateStep2(age: val.toInt())),
          const SizedBox(height: 16),
          _buildGenderSelector(state.sex, (val) => notifier.updateStep2(sex: val)),
          const SizedBox(height: 24),
          _buildMetricRow('Height (cm)', '${state.height}', 100, 220, (val) => notifier.updateStep2(height: val)),
          const SizedBox(height: 16),
          _buildMetricRow('Weight (kg)', '${state.weight}', 30, 150, (val) => notifier.updateStep2(weight: val)),
          const SizedBox(height: 24),
          _buildTextField('Country', _countryController, hint: 'e.g., United States'),
          const SizedBox(height: 16),
          _buildTextField('City', _cityController, hint: 'e.g., San Francisco'),
          const SizedBox(height: 16),
          _buildTextField('Occupation', _occupationController, hint: 'e.g., Software Engineer'),
          const SizedBox(height: 24),
          const Text('Primary Goal', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: goals.map((g) => _BiologicalChip(
              label: g,
              isSelected: state.primaryGoal == g,
              onTap: () => notifier.updateStep2(goal: g),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── STEP 2: LIFESTYLE ─────────────────────────────────────────────────────
  Widget _buildLifestyleStep() {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return _StepLayout(
      title: 'Lifestyle Routine',
      subtitle: 'Analyze your routines. Daily movement patterns are used to evaluate metabolic post-meal glucose clearance rate limits.',
      onContinue: () {
        notifier.updateStep3(
          sleepTime: _sleepTimeController.text.trim(),
          wakeTime: _wakeTimeController.text.trim(),
          exercise: _exerciseController.text.trim(),
        );
        _onNext();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Sleep Time', _sleepTimeController, hint: 'e.g., 22:30')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Wake Time', _wakeTimeController, hint: 'e.g., 06:30')),
            ],
          ),
          const SizedBox(height: 24),
          _buildChoiceSelector(
            label: 'Activity Level',
            selected: state.activityLevel,
            options: const ['Sedentary', 'Light', 'Moderate', 'Active', 'Athlete'],
            onSelect: (val) => notifier.updateStep3(activityLevel: val),
          ),
          const SizedBox(height: 24),
          _buildTextField('Exercise Details', _exerciseController, hint: 'e.g., 3 days/week gym'),
          const SizedBox(height: 24),
          _buildChoiceSelector(
            label: 'Smoking',
            selected: state.smoking,
            options: const ['No', 'Yes', 'Occasionally'],
            onSelect: (val) => notifier.updateStep3(smoking: val),
          ),
          const SizedBox(height: 24),
          _buildChoiceSelector(
            label: 'Alcohol Consumption',
            selected: state.alcohol,
            options: const ['No', 'Yes', 'Occasionally'],
            onSelect: (val) => notifier.updateStep3(alcohol: val),
          ),
          const SizedBox(height: 24),
          _buildMetricRow('Daily Stress Level', '${state.stressLevel}', 1, 10, (val) => notifier.updateStep3(stressLevel: val.toInt())),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── STEP 3: FOOD & NUTRITION ──────────────────────────────────────────────
  Widget _buildFoodStep() {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return _StepLayout(
      title: 'Food & Hydration',
      subtitle: 'Log your typical water intake to measure daily hydration depth against weight-based targets.',
      onContinue: () {
        notifier.updateStep4(
          mealTiming: _mealTimingController.text.trim(),
        );
        _onNext();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChoiceSelector(
            label: 'Diet Preference',
            selected: state.dietPreference,
            options: const ['Veg', 'Non-Veg'],
            onSelect: (val) => notifier.updateStep4(dietPreference: val),
          ),
          const SizedBox(height: 24),
          _buildMetricRow('Daily Water Intake (L)', state.waterIntake.toStringAsFixed(1), 0.5, 6.0, (val) => notifier.updateStep4(waterIntake: val)),
          const SizedBox(height: 24),
          _buildTextField('Typical Meal Timings', _mealTimingController, hint: 'e.g., Breakfast 8 AM, Lunch 1 PM, Dinner 8 PM'),
          const SizedBox(height: 24),
          const Text('Supplements', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildSupplementChips(state.supplements, (list) => notifier.updateStep4(supplements: list)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── STEP 4: FAMILY RISK ───────────────────────────────────────────────────
  Widget _buildRiskStep() {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return _StepLayout(
      title: 'Family History Risk',
      subtitle: 'Family history maps predispositions for glucose regulation and cardiovascular resilience.',
      onContinue: _onNext,
      child: Column(
        children: [
          _PermissionTile(
            title: 'Diabetes History',
            desc: 'Include immediate family (parents, siblings).',
            icon: Icons.biotech_rounded,
            isEnabled: state.hasDiabetesRisk,
            onToggle: (v) => notifier.updateStep5(hasDiabetesRisk: v),
          ),
          _PermissionTile(
            title: 'Heart Disease History',
            desc: 'Stroke, cardiac arrest, or coronary history.',
            icon: Icons.favorite_rounded,
            isEnabled: state.hasHeartDiseaseRisk,
            onToggle: (v) => notifier.updateStep5(hasHeartDiseaseRisk: v),
          ),
          _PermissionTile(
            title: 'Cancer History',
            desc: 'Any prior diagnosed oncology cases.',
            icon: Icons.bubble_chart_rounded,
            isEnabled: state.hasCancerRisk,
            onToggle: (v) => notifier.updateStep5(hasCancerRisk: v),
          ),
          _PermissionTile(
            title: 'Thyroid Conditions',
            desc: 'Hyperthyroidism or hypothyroidism history.',
            icon: Icons.shield_rounded,
            isEnabled: state.hasThyroidRisk,
            onToggle: (v) => notifier.updateStep5(hasThyroidRisk: v),
          ),
          _PermissionTile(
            title: 'Blood Pressure Conditions',
            desc: 'Chronic hypertension or BP swings.',
            icon: Icons.speed_rounded,
            isEnabled: state.hasBloodPressureRisk,
            onToggle: (v) => notifier.updateStep5(hasBloodPressureRisk: v),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  Widget _buildTextField(String label, TextEditingController controller, {required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            fillColor: NEColors.surfaceLight,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: NEColors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(color: NEColors.accent, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: NEColors.accent,
            inactiveTrackColor: Colors.white10,
            thumbColor: NEColors.accent,
            overlayColor: NEColors.accent.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: (double.tryParse(value) ?? min).clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(String selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Biological Sex', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final isSelected = selected == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(g),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? NEColors.accent.withValues(alpha: 0.2) : NEColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? NEColors.accent : Colors.white10, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      g,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChoiceSelector({
    required String label,
    required String selected,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onSelect(opt),
              selectedColor: NEColors.accent.withValues(alpha: 0.2),
              backgroundColor: NEColors.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: isSelected ? NEColors.accent : Colors.transparent),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSupplementChips(List<String> selectedList, Function(List<String>) onChange) {
    final list = ['Vitamin D', 'Vitamin B12', 'Omega-3', 'Magnesium', 'Zinc', 'Multivitamin'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: list.map((supp) {
        final isSelected = selectedList.contains(supp);
        return ChoiceChip(
          label: Text(supp),
          selected: isSelected,
          onSelected: (selected) {
            final updated = List<String>.from(selectedList);
            if (selected) {
              updated.add(supp);
            } else {
              updated.remove(supp);
            }
            onChange(updated);
          },
          selectedColor: NEColors.accent.withValues(alpha: 0.2),
          backgroundColor: NEColors.surfaceLight,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: isSelected ? NEColors.accent : Colors.transparent),
        );
      }).toList(),
    );
  }
}

class _StepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onContinue;
  const _StepLayout({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(color: NEColors.textSecondary, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 24),
          Expanded(child: SingleChildScrollView(child: child)),
          const SizedBox(height: 16),
          _PulseButton(onTap: onContinue, label: 'Continue'),
        ],
      ),
    );
  }
}

class _BiologicalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BiologicalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? NEColors.accent.withValues(alpha: 0.2) : NEColors.surfaceLight,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? NEColors.accent : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.04, 1.04), duration: 200.ms, curve: Curves.easeOutBack),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool isEnabled;
  final Function(bool) onToggle;

  const _PermissionTile({
    required this.title,
    required this.desc,
    required this.icon,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NEColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isEnabled ? NEColors.accent.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEnabled ? NEColors.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isEnabled ? NEColors.accent : Colors.white24, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.white38, height: 1.3),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: NEColors.accent,
            activeTrackColor: NEColors.accent.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PulseButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _PulseButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: NEColors.morningGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: NEColors.accent.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 3,
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white38),
    );
  }
}
