// ==============================================================================
// Nutrient Earth — Profile & Home Dashboard Screen (/profile)
// Exact pixel perfection: #FAF8F5 background, #EAF0EC cards, serif headers
// Features Living Avatar Engine with AvatarStateSwitcher (110x110px)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../today/state/today_state.dart';
import 'widgets/avatar_state_switcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayState = ref.watch(todayNotifierProvider);
    final userProfile = todayState.userProfile;
    final displayName = userProfile?.displayName.trim();
    final effectiveName = (displayName != null && displayName.isNotEmpty && displayName != 'User')
        ? displayName
        : null;

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMM yyyy').format(now).toUpperCase();

    final hour = now.hour;
    String greetingTime = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greetingTime = 'Good afternoon';
    } else if (hour >= 17 || hour < 5) {
      greetingTime = 'Good evening';
    }

    final greetingText = effectiveName != null
        ? '$greetingTime, $effectiveName.'
        : '$greetingTime.';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Exact #FAF8F5 cream canvas
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00251D), size: 22),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE4E9E2)),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/Icon-192.png',
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.eco,
                    size: 18,
                    color: Color(0xFF00251D),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Nutrient Earth',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00251D),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Greeting Card with Living Avatar Engine
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0EC), // #EAF0EC sage green card
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD5E2D8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A0B2B26),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4F6359),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            greetingText,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF051F20),
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Let's find evidence-based answers for a healthier you.",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13.5,
                              color: Color(0xFF4F6359),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // AvatarStateSwitcher (110x110px Circle)
                    const AvatarStateSwitcher(size: 110.0),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search Bar
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFD5E2D8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A051F20),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, size: 22, color: Color(0xFF4F6359)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ask about food, fitness or health...',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Color(0xFF717975),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
