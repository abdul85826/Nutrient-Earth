import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import './widgets/history_graph.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProgressProvider);

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
                children: [
                  _buildCustomAppBar(context),
                  const SizedBox(height: 32),
                  _buildProfileSection(userProfile),
                  const SizedBox(height: 40),
                  _buildStatsSection(),
                  const SizedBox(height: 40),
                  const HistoryGraph(
                    title: 'BIOLOGICAL STABILITY',
                    dataPoints: [180.0, 165.0, 150.0, 142.0, 135.0, 128.0, 120.0],
                    unit: 'mg/dL',
                  ),
                  const SizedBox(height: 40),
                  _buildJourneySummary(context),
                  const SizedBox(height: 40),
                  _buildBadgesSection(context),
                  const SizedBox(height: 40),
                  _buildRewardsSection(context),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'IDENTITY',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: AppTheme.glassStyle(opacity: 0.05, borderRadius: 12),
            child: const Icon(Icons.settings_outlined, color: Colors.white60, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(UserProfile profile) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              image: DecorationImage(
                image: NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=Arjun'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Arjun Sharma',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.nutrientGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.nutrientGreen.withValues(alpha: 0.2)),
          ),
          child: const Text(
            'BIOLOGICAL LEVEL 4',
            style: TextStyle(color: AppColors.nutrientGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('STREAK', '12', Icons.local_fire_department_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('CREDITS', '2.4k', Icons.token_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('RANK', '#42', Icons.leaderboard_rounded)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        children: [
          Icon(icon, color: AppColors.nutrientGreen, size: 22),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildJourneySummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('EVOLUTION LOG', style: Theme.of(context).textTheme.labelLarge),
              const Text('ACTIVE: 12D', style: TextStyle(color: AppColors.nutrientGreen, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 28),
          _buildJourneyMilestone('LOG 01', 'Biological initialization complete.', true),
          _buildJourneyMilestone('LOG 05', 'Sugar baseline reduced by 14%.', true),
          _buildJourneyMilestone('LOG 10', 'First botanical protocol activated.', true),
          _buildJourneyMilestone('LOG 14', 'Deep energy restoration target.', false),
        ],
      ),
    );
  }

  Widget _buildJourneyMilestone(String day, String title, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.nutrientGreen.withValues(alpha: 0.1) : Colors.transparent,
              border: Border.all(color: completed ? AppColors.nutrientGreen : Colors.white12, width: 2),
            ),
            child: completed ? const Icon(Icons.check, color: AppColors.nutrientGreen, size: 10) : null,
          ),
          const SizedBox(width: 16),
          Text(
            day,
            style: TextStyle(color: completed ? AppColors.nutrientGreen : Colors.white24, fontWeight: FontWeight.bold, fontSize: 10),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: completed ? Colors.white : Colors.white38,
                fontSize: 13,
                fontWeight: completed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BIO-ACHIEVEMENTS', style: Theme.of(context).textTheme.labelLarge),
            const Text('3/5 ACTIVE', style: TextStyle(color: AppColors.nutrientGreen, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBadge('🧬', 'INIT'),
            _buildBadge('📉', 'FLATLINE'),
            _buildBadge('🧪', 'CHEMIST'),
            _buildBadge('⚡', 'VOLT'),
            _buildBadge('🔒', 'LOCKED', isLocked: true),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String emoji, String title, {bool isLocked = false}) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: AppTheme.glassStyle(opacity: isLocked ? 0.02 : 0.08, borderRadius: 16),
          alignment: Alignment.center,
          child: Text(emoji, style: TextStyle(fontSize: 28, color: isLocked ? Colors.white10 : null)),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(color: isLocked ? Colors.white24 : Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: -5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.black, size: 24),
              const SizedBox(width: 12),
              const Text('NE WALLET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('2,450', style: TextStyle(color: Colors.black, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: -2)),
          const Text('AVAILABLE CREDITS', style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('REDEEM FOR PROTOCOLS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
