import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import './widgets/problem_picker.dart';
import './widgets/animated_organ_graph.dart';

class BodyScreen extends ConsumerStatefulWidget {
  const BodyScreen({super.key});

  @override
  ConsumerState<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends ConsumerState<BodyScreen> {
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _recoveryProgress = 0.42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomAppBar(context),
                  const SizedBox(height: 32),
                  const ProblemPicker(),
                  const SizedBox(height: 48),
                  _buildHealingSection(),
                  const SizedBox(height: 48),
                  _buildManualLoggingSection(),
                  const SizedBox(height: 120),
                ],
              ),
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

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BODY',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Precise biological re-engineering.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHealingSection() {
    final area = ref.watch(personaProvider);
    String organ = 'Vital Organs';
    String stressMetric = 'STRESS LEVEL: 42%';
    String reversalStatus = '7% STABILIZED';

    switch (area) {
      case ProblemArea.sugar:
        organ = 'Pancreas & Liver';
        stressMetric = 'STRESS LEVEL: 38%';
        reversalStatus = 'REVERSAL: 12%';
        break;
      case ProblemArea.energy:
        organ = 'Cellular Mitochondria';
        stressMetric = 'ATP OUTPUT: 62%';
        reversalStatus = 'RECHARGED: 18%';
        break;
      case ProblemArea.weight:
        organ = 'Metabolic System';
        stressMetric = 'OXIDATION: 22%';
        reversalStatus = 'BURNED: 2.1kg';
        break;
      case ProblemArea.stress:
        organ = 'Adrenal Glands';
        stressMetric = 'CORTISOL: HIGH';
        reversalStatus = 'CALMED: 15%';
        break;
      case ProblemArea.bp:
        organ = 'Cardiovascular Wall';
        stressMetric = 'WALL STRESS: 120mmHg';
        reversalStatus = 'FLOW: STABLE';
        break;
      default:
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BIO-INTELLIGENCE', style: Theme.of(context).textTheme.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.nutrientGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.nutrientGreen.withValues(alpha: 0.2)),
                ),
                child: Text(reversalStatus, style: const TextStyle(color: AppColors.nutrientGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AnimatedOrganGraph(progress: _recoveryProgress, label: organ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: AppColors.nutrientGreen, size: 18),
              const SizedBox(width: 12),
              Text(
                stressMetric,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.2),
              ),
              const Spacer(),
              const Text(
                '↑ 3.2% IMPROVEMENT',
                style: TextStyle(color: AppColors.nutrientGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualLoggingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CORE BIOMETRICS', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 24),
        _buildInputField('GLUCOSE (mg/dL)', _sugarController, '120', 'This level indicates pancreatic load.'),
        const SizedBox(height: 20),
        _buildInputField('BLOOD PRESSURE', _bpController, '120/80', 'Arterial tension baseline.'),
        const SizedBox(height: 20),
        _buildInputField('WEIGHT (kg)', _weightController, '72.5', 'Metabolic load indicator.'),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: -5),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _recoveryProgress = (_recoveryProgress + 0.03).clamp(0, 1.0);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biological logs recorded. Optimization sequence starting.'),
                    backgroundColor: AppColors.nutrientGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.nutrientGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('CALIBRATE BIO-SYSTEM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, [String insight = '']) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          cursorColor: AppColors.nutrientGreen,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1), fontSize: 16),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.nutrientGreen, width: 2),
            ),
          ),
        ),
        if (insight.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white24, size: 14),
              const SizedBox(width: 8),
              Text(
                insight,
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
