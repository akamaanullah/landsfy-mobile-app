import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  // Mock list of additional images for the slider
  late final List<String> _propertyImages;

  @override
  void initState() {
    super.initState();
    // Use the main image, and duplicate/mock others if none are provided
    final mainImage = widget.property['image'] ?? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80';
    _propertyImages = [
      mainImage,
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=600&q=80',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.property['title'] ?? 'Luxury Property';
    final location = widget.property['location'] ?? 'Location, Pakistan';
    final price = widget.property['price'] ?? 'Contact for Price';
    final beds = widget.property['beds'] ?? 0;
    final baths = widget.property['baths'] ?? 0;
    final area = widget.property['area'] ?? 'N/A';
    final badgeType = widget.property['badgeType'] ?? 'Regular';
    final purpose = widget.property['purpose'] ?? 'Buy';

    Color badgeColor = AppColors.primary;
    if (badgeType == 'Diamond') {
      badgeColor = AppColors.diamond;
    } else if (badgeType == 'Platinum') {
      badgeColor = AppColors.platinum;
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Slider & Pagination Indicator
                _buildImageSlider(),

                // Main Details Card
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Row(
                        children: [
                          if (badgeType != 'Regular') ...[
                            _buildCapsuleBadge(badgeType.toString().toUpperCase(), badgeColor),
                            const SizedBox(width: 8),
                          ],
                          _buildCapsuleBadge(purpose.toString().toUpperCase(), AppColors.primaryLight),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price Tag
                      Text(
                        price,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 10),

                      // Location Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.3,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 24),

                      // Specifications Box
                      Text(
                        'Specifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildSpecificationsRow(beds, baths, area, purpose),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 28),

                      // Description Box
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This premium property offers high-end finishes, modern architecture, and a spacious layout. Situated in a secure, fully-developed neighborhood with access to round-the-clock utilities and amenities. Perfect for families looking for an elegant lifestyle or investors looking for solid returns.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMain,
                              height: 1.5,
                            ),
                      ),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 28),

                      // Amenities Grid
                      Text(
                        'Key Amenities & Utilities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                      ),
                      const SizedBox(height: 14),
                      _buildAmenitiesGrid(),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 28),

                      // Agent Information
                      Text(
                        'Listing Agent',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildAgentCard(),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 28),

                      // Related Listings
                      Text(
                        'Related Properties',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildRelatedPropertiesSection(),

                      // Padding at bottom to avoid blocking by sticky action bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Custom Back Button and Favorite Icon
          _buildFloatingHeaderControls(),

          // Sticky Bottom Communication Bar
          _buildStickyBottomActionBar(),
        ],
      ),
    );
  }

  // IMAGE SLIDER
  Widget _buildImageSlider() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _propertyImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: _propertyImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: AppColors.primarySoft,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primarySoft,
                  child: const Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                ),
              );
            },
          ),
          // Gradient shadow for visibility of controls
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Pagination Indicator dots
          Positioned(
            bottom: 16,
            left: 20,
            child: Row(
              children: List.generate(
                _propertyImages.length,
                (index) => Container(
                  width: _currentImageIndex == index ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index ? AppColors.accent : Colors.white70,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          // Photo Counter Badge
          Positioned(
            bottom: 16,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentImageIndex + 1}/${_propertyImages.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FLOATING CONTROLS
  Widget _buildFloatingHeaderControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          // Favorite button
          GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite ? 'Added to Favorites!' : 'Removed from Favorites'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.redAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CAPSULE BADGE
  Widget _buildCapsuleBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // SPECIFICATIONS GRID ROW
  Widget _buildSpecificationsRow(int beds, int baths, String area, String purpose) {
    return Row(
      children: [
        if (beds > 0) ...[
          Expanded(child: _buildSpecCard(Icons.king_bed_outlined, '$beds Beds', 'Bedroom')),
          const SizedBox(width: 8),
        ],
        if (baths > 0) ...[
          Expanded(child: _buildSpecCard(Icons.bathtub_outlined, '$baths Baths', 'Restroom')),
          const SizedBox(width: 8),
        ],
        Expanded(child: _buildSpecCard(Icons.zoom_out_map_rounded, area, 'Area Size')),
        const SizedBox(width: 8),
        Expanded(child: _buildSpecCard(Icons.vpn_key_outlined, purpose, 'Purpose')),
      ],
    );
  }

  Widget _buildSpecCard(IconData icon, String value, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // AMENITIES GRID
  Widget _buildAmenitiesGrid() {
    final amenities = [
      {'name': 'Sui Gas', 'icon': Icons.local_fire_department_rounded},
      {'name': 'Electricity', 'icon': Icons.flash_on_rounded},
      {'name': 'Water Supply', 'icon': Icons.water_drop_rounded},
      {'name': '24/7 Security', 'icon': Icons.security_rounded},
      {'name': 'Covered Parking', 'icon': Icons.directions_car_rounded},
      {'name': 'Boundary Wall', 'icon': Icons.border_all_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final item = amenities[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, color: AppColors.primaryLight, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item['name'].toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // AGENT CARD
  Widget _buildAgentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Agent Image
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
              height: 52,
              width: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          // Agent Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Sarah Khan',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Defence Realtors (Pvt.) Ltd.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // View Profile Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Profile',
              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // RELATED PROPERTIES SECTION
  Widget _buildRelatedPropertiesSection() {
    final List<Map<String, dynamic>> relatedProperties = [
      {
        'title': 'Premium 3-Bed Apartment',
        'location': 'DHA Phase 6, Karachi',
        'price': 'PKR 2.5 Lakh / month',
        'beds': 3,
        'baths': 3,
        'area': '2000 Sq. Ft.',
        'badgeType': 'Platinum',
        'image': 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=600&q=80',
        'purpose': 'Rent',
      },
      {
        'title': '500 Sq. Yd. Prime Plot',
        'location': 'Bahria Town Phase 2, Lahore',
        'price': 'PKR 3.2 Crore',
        'beds': 0,
        'baths': 0,
        'area': '500 Sq. Yd.',
        'badgeType': 'Featured',
        'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=600&q=80',
        'purpose': 'Buy',
      },
      {
        'title': 'Modern Office Suite',
        'location': 'Blue Area, Islamabad',
        'price': 'PKR 1.2 Lakh / month',
        'beds': 0,
        'baths': 2,
        'area': '1200 Sq. Ft.',
        'badgeType': 'Regular',
        'image': 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80',
        'purpose': 'Rent',
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: relatedProperties.length,
        itemBuilder: (context, index) {
          final prop = relatedProperties[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetailsScreen(property: prop),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 14, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: prop['image'].toString(),
                      height: 110,
                      width: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.bgLight),
                      errorWidget: (context, url, error) => const Icon(Icons.home),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prop['price'].toString(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prop['title'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                prop['location'].toString(),
                                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // STICKY BOTTOM ACTION BAR
  Widget _buildStickyBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Email/Message Agent button
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.mail_outline_rounded, color: AppColors.textMain, size: 24),
            ),
            const SizedBox(width: 12),
            // Call Agent Button
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Call Agent',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // WhatsApp Button
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'WhatsApp',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


