import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../today/widgets/success_stories_carousel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlowScreen extends StatefulWidget {
  const FlowScreen({super.key});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  String _selectedTopic = 'Sugar Control';
  final List<String> _topics = ['Sugar Control', 'Weight Loss', 'Energy Boost', 'Mental Calm', 'Beginners'];
  
  List<Map<String, dynamic>> _contentList = [];
  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    _fetchFlowContent();
  }

  Future<void> _fetchFlowContent() async {
    try {
      final res = await Supabase.instance.client.from('flow_content').select();
      if (res.isNotEmpty && mounted) {
        setState(() {
          _contentList = List<Map<String, dynamic>>.from(res);
          _isLoadingContent = false;
        });
        return;
      }
    } catch (e) {
      // Fallback
    }

    // Local fallback for testing unpopulated schema
    if (mounted) {
      setState(() {
        _contentList = [
          {'title': 'Morning Sunlight Routine', 'insight': 'Expose your eyes to early sun (before 9AM) to reset cortisol levels and spike energy naturally.', 'tag': '⚡ ENERGY RISE'},
          {'title': 'Herbal Cinnamon Hack', 'insight': 'Add 2g of Ceylon cinnamon to your morning tea to reduce post-meal sugar spikes by 24%.', 'tag': '🧪 SUGAR CONTROL'},
          {'title': 'The 5-Min Micro-Walk', 'insight': 'Just 5 minutes of walking after every meal is more effective for weight loss than a 60-min gym session once a day.', 'tag': '⚖️ WEIGHT LOSS'}
        ];
        _isLoadingContent = false;
      });
    }
  }

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
                _buildCustomAppBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    children: [
                      const SuccessStoriesCarousel(),
                      const SizedBox(height: 36),
                      _buildTopicSelector(),
                      const SizedBox(height: 36),
                      _buildMomentsSection(),
                      const SizedBox(height: 36),
                      Text(
                        'FOR YOUR BIOLOGY',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 20),
                      if (_isLoadingContent)
                        const Center(child: CircularProgressIndicator(color: AppColors.nutrientGreen))
                      else
                        ..._contentList.map((c) => _buildContentCard(c['title'] ?? '', c['insight'] ?? '', c['tag'] ?? '')),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: -5),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showUploadCard(context),
          backgroundColor: AppColors.nutrientGreen,
          icon: const Icon(Icons.add_rounded, color: Colors.black),
          label: const Text('UPLOAD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
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

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FLOW',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'The collective biological pulse.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final topic = _topics[index];
          final isSelected = topic == _selectedTopic;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTopic = topic),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      )
                    : AppTheme.glassStyle(opacity: 0.05, borderRadius: 20),
                child: Text(
                  topic.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentCard(String title, String insight, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.nutrientGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.nutrientGreen.withValues(alpha: 0.2)),
                ),
                child: Text(tag, style: const TextStyle(color: AppColors.nutrientGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.white24),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(
            insight,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.6, fontSize: 14),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _buildActionIcon(Icons.favorite_outline_rounded, '2.4k'),
              const SizedBox(width: 24),
              _buildActionIcon(Icons.chat_bubble_outline_rounded, '128'),
              const Spacer(),
              _buildActionIcon(Icons.share_outlined, ''),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Routine synced to your biological runway.'),
                    backgroundColor: AppColors.nutrientGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('💡 TRY THIS ROUTINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(count, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildMomentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LIVE MOMENTS', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildMomentCard('🧘', 'Box Breath', '1.2k active'),
              _buildMomentCard('🚶', 'Meal Walk', '840 active'),
              _buildMomentCard('🍵', 'Herbal Fix', '2.1k active'),
              _buildMomentCard('🥑', 'Clean Eat', '3.5k active'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMomentCard(String icon, String label, String active) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: AppTheme.glassStyle(opacity: 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(active, style: const TextStyle(color: AppColors.nutrientGreen, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showUploadCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text('CONTRIBUTE TO FLOW', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 24),
            _buildUploadOption(Icons.show_chart_rounded, 'Share Bio-Progress', 'Inspire others with your 7-day trends.'),
            _buildUploadOption(Icons.timer_outlined, 'Share Routine', 'What protocol worked for you today?'),
            _buildUploadOption(Icons.camera_alt_outlined, 'Visual Impact', 'Share a photo of your NE preparation.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: AppColors.nutrientGreen),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
      onTap: () => Navigator.pop(context),
    );
  }
}
