import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_models.dart';
import '../../core/providers/app_providers.dart';
import '../today/widgets/success_stories_carousel.dart';
import 'dart:ui';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _currentCity = 'Bangalore';
  String _currentLocality = 'Indiranagar';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }
      
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        if (mounted) {
          setState(() {
            _currentCity = placemarks.first.locality ?? 'Bangalore';
            _currentLocality = placemarks.first.subLocality ?? 'Store Center';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildStoreTab(),
                      _buildLibraryTab(),
                      _buildDoctorTab(),
                    ],
                  ),
                ),
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

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPLORE',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          Container(
            height: 48,
            decoration: AppTheme.glassStyle(opacity: 0.05, borderRadius: 24),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: AppColors.primaryGradient,
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: Colors.black),
              unselectedLabelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'STORE'),
                Tab(text: 'LIBRARY'),
                Tab(text: 'DOCTOR'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STORE TAB
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildStoreTab() {
    final products = _generateProducts();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationStrip(),
          const SizedBox(height: 28),
          const SuccessStoriesCarousel(),
          const SizedBox(height: 36),
          Text(
            'NE FORMULATIONS',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final urgencyOptions = [
                'Only 7 units left at $_currentLocality',
                '108 people bought this in $_currentCity today',
                'Recommended for your 7-Day Reset',
                'Freshly stocked today',
              ];
              return _buildProductCard(products[index], urgencyOptions[index % urgencyOptions.length]);
            },
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildLocationStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: AppTheme.glassStyle(opacity: 0.03),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.nutrientGreen, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isLoadingLocation ? 'Locating nearest NE Store...' : 'DELIVERING TO: $_currentLocality',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: Colors.white70),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white30, size: 18),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, String urgencyText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(_getEmoji(product.name), style: const TextStyle(fontSize: 44)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '₹${product.price.toInt()}',
                style: const TextStyle(color: AppColors.nutrientGreen, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              const Icon(Icons.star, color: AppColors.nutrientGreen, size: 10),
              const Text(' 4.9', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            urgencyText,
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => _showUPIPaymentSheet(context, product),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ACTIVATE', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LIBRARY TAB
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildLibraryTab() {
    final userProfile = ref.watch(userProgressProvider);
    final isLocked = userProfile.completionPercentage < 1.0;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedGuide(),
              const SizedBox(height: 36),
              Text('POPULAR PROTOCOLS', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 20),
              _buildGuideListItem('Glucose Masterclass', '30-day biological reset.', '15m'),
              _buildGuideListItem('Circadian Repair', 'Optimize your deep sleep.', '10m'),
              _buildGuideListItem('Inflammation Control', 'The silent recovery guide.', '12m'),
              const SizedBox(height: 120),
            ],
          ),
        ),
        if (isLocked) _buildLockedOverlay('LIBRARY GATED', 'Complete your body profile to unlock the full NE Knowledge Library.'),
      ],
    );
  }

  Widget _buildFeaturedGuide() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: -5),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.nutrientGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('NEW MASTERCLASS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1)),
            ),
            const SizedBox(height: 12),
            const Text('The DNA Reset Protocol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 6),
            Text('Advanced biological restoration for high-stress systems.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideListItem(String title, String sub, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: AppColors.nutrientGreen, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DOCTOR TAB
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildDoctorTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsultationBanner(),
          const SizedBox(height: 40),
          Text('LAB TESTS', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 20),
          _buildLabTestCard('Metabolic Health Panel', 'Full blood-work for glucose, A1C, and lipids.', '₹1,499'),
          _buildLabTestCard('DNA Bio-Age Test', 'Determine your internal biological age.', '₹4,999'),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildConsultationBanner() {
    return Container(
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
          const Icon(Icons.medication_liquid_outlined, color: Colors.black, size: 36),
          const SizedBox(height: 20),
          const Text('BIOLOGICAL CONSULT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text(
            'Speak with a specialist doctor to interpret your biometric trends.',
            style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
          ),
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
              child: const Text('BOOK NOW (₹499)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabTestCard(String title, String sub, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(price, style: const TextStyle(color: AppColors.nutrientGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.home_outlined, color: AppColors.nutrientGreen, size: 16),
              const SizedBox(width: 8),
              Text('FREE HOME COLLECTION', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay(String title, String message) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.6),
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, color: AppColors.nutrientGreen, size: 72),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/body'),
                  child: const Text('GO TO BODY TAB'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUPIPaymentSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text('ACTIVATE PROTOCOL', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            Text('₹${product.price.toInt()}', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.qr_code_2, size: 140, color: Colors.black),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['GPAY', 'PHONEPE', 'PAYTM'].map((name) => Column(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                    child: const Icon(Icons.account_balance_wallet_outlined, size: 22, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              )).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Protocol Activation Requested.'), backgroundColor: AppColors.nutrientGreen));
                },
                child: const Text('ONE-TAP PAYMENT'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────────
  String _getEmoji(String name) {
    if (name.contains('Glucose')) return '🧪';
    if (name.contains('Energy')) return '⚡';
    if (name.contains('Calm')) return '🧘';
    if (name.contains('Heart')) return '🫀';
    if (name.contains('Metabolic')) return '⚖️';
    return '🌿';
  }

  List<Product> _generateProducts() {
    return [
      Product(id: '1', name: '7-Day Sugar Reset Pack', price: 499, benefit: 'Reverses glucose spikes.', primaryHerbs: ['Cinnamon', 'Fenugreek'], imagePath: ''),
      Product(id: '2', name: 'Cellular Energy Protocol', price: 299, benefit: 'Mitochondrial spark.', primaryHerbs: ['Dates', 'Ashwagandha'], imagePath: ''),
      Product(id: '3', name: 'Cortisol Control Drops', price: 199, benefit: 'Adrenal calming.', primaryHerbs: ['Tulsi', 'Brahmi'], imagePath: ''),
      Product(id: '4', name: 'Heart Wall Reset', price: 499, benefit: 'Arterial reversal.', primaryHerbs: ['Arjuna', 'Garlic'], imagePath: ''),
    ];
  }
}
