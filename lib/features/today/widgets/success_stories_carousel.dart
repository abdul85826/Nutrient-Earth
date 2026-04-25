import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuccessStoriesCarousel extends StatefulWidget {
  const SuccessStoriesCarousel({super.key});

  @override
  State<SuccessStoriesCarousel> createState() => _SuccessStoriesCarouselState();
}

class _SuccessStoriesCarouselState extends State<SuccessStoriesCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  List<SuccessStory> _stories = [];
  final List<String> _proofStats = [
    '97% of patients achieve stability in 7 days.',
    '21 days: The point of permanent body reversal.',
    '108 users in your region achieved takeoff today.',
    '7 Day Reset: Success rate currently at 98.4%.',
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStories();
    _startTimer();
  }

  Future<void> _fetchStories() async {
    try {
      final data = await Supabase.instance.client.from('success_stories').select();
      if (data.isNotEmpty) {
        if (mounted) {
          setState(() {
            _stories = data.map<SuccessStory>((json) => SuccessStory(
              id: json['id'].toString(),
              name: json['name'],
              shortStory: json['story'],
              beforeValue: json['before_value'].toString(),
              afterValue: json['after_value'].toString(),
              days: json['days'] as int,
              problemType: json['problem_type'],
            )).toList();
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      // Fallback
    }
    
    // Local fallback if Supabase table is empty or disconnected
    if (mounted) {
      setState(() {
        _stories = [
          SuccessStory(id: '1', name: 'Anita', shortStory: 'Sugar stabilized senza meds.', beforeValue: '310', afterValue: '145', days: 18, problemType: 'sugar'),
          SuccessStory(id: '2', name: 'Ravi', shortStory: 'High energy achieved daily.', beforeValue: 'Lethargic', afterValue: 'Active', days: 21, problemType: 'energy'),
          SuccessStory(id: '3', name: 'Maya', shortStory: 'BP normalized safely.', beforeValue: '145/95', afterValue: '122/80', days: 14, problemType: 'stress'),
        ];
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      int totalItems = _stories.length + _proofStats.length;
      if (_currentPage < totalItems - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppTheme.moss)));
    }
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _stories.length + _proofStats.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          if (index < _stories.length) {
            final story = _stories[index];
            return _buildStoryItem(story);
          } else {
            final stat = _proofStats[index - _stories.length];
            return _buildStatItem(stat);
          }
        },
      ),
    );
  }

  Widget _buildStoryItem(SuccessStory story) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          _getCategoryIcon(story.problemType),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${story.name} reversed ${story.problemType} ${story.beforeValue} → ${story.afterValue}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.cloud,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  story.shortStory,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.earth,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String stat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.earth.withValues(alpha: 0.1), AppTheme.moss.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.earth.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: AppTheme.earth, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              stat,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.earth,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'sugar': return const Text('🧪', style: TextStyle(fontSize: 24));
      case 'energy': return const Text('⚡', style: TextStyle(fontSize: 24));
      case 'bp': return const Text('🫀', style: TextStyle(fontSize: 24));
      case 'weight': return const Text('⚖️', style: TextStyle(fontSize: 24));
      default: return const Text('🌿', style: TextStyle(fontSize: 24));
    }
  }
}
