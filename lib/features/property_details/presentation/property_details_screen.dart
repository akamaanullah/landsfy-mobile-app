import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/data/models/property_model.dart';
import '../data/services/property_details_api_service.dart';
import '../../../core/services/favorites_manager.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PropertyDetailsApiService _apiService = PropertyDetailsApiService();
  final PageController _pageController = PageController();
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _propertyData = {};
  List<dynamic> _similarProperties = [];

  bool _isFavorite = false;
  int _currentImageIndex = 0;
  List<String> _propertyImages = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate slider image from widget.property so it renders immediately
    final mainImage = widget.property['image'] ?? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80';
    _propertyImages = [mainImage];

    // Check favorite status immediately
    final int pId = int.tryParse(widget.property['id']?.toString() ?? '') ?? 0;
    if (pId > 0) {
      FavoritesManager.isFavorite(pId).then((val) {
        if (mounted) {
          setState(() {
            _isFavorite = val;
          });
        }
      });
    }

    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final slug = widget.property['slug']?.toString() ?? '';
      if (slug.isEmpty) {
        throw Exception('Property slug is missing');
      }
      debugPrint("Loading property details for slug: '$slug'");
      final result = await _apiService.getPropertyDetails(slug);
      if (mounted) {
        setState(() {
          _propertyData = result['data'] as Map<String, dynamic>;
          _similarProperties = result['similar'] as List<dynamic>? ?? [];
          
          // Parse images
          final rawImages = _propertyData['images'] as List<dynamic>? ?? [];
          debugPrint("Raw images list from API count: ${rawImages.length}");
          final List<String> loadedImages = rawImages.map<String>((img) {
            final url = img['image_url']?.toString() ?? '';
            if (url.startsWith('http://') || url.startsWith('https://')) {
              return url;
            }
            final clean = url.startsWith('/') ? url.substring(1) : url;
            return 'https://landsfy.com/$clean';
          }).toList();
          
          if (loadedImages.isNotEmpty) {
            _propertyImages = loadedImages;
            debugPrint("Successfully loaded ${_propertyImages.length} images: $_propertyImages");
          } else {
            debugPrint("Warning: loadedImages is empty, using fallback main image.");
          }

          final int pId = int.tryParse(_propertyData['id']?.toString() ?? '') ?? 0;
          FavoritesManager.isFavorite(pId).then((val) {
            if (mounted) {
              setState(() {
                _isFavorite = val;
              });
            }
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSkeletonLine({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadPropertyDetails,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = _propertyData['title']?.toString() ?? widget.property['title'] ?? 'Property Details';
    
    // Format price
    String price = '';
    if (_propertyData['price'] != null) {
      double rawPrice = double.tryParse(_propertyData['price'].toString()) ?? 0;
      if (rawPrice >= 10000000) {
        final crore = rawPrice / 10000000;
        price = 'PKR ${crore.toStringAsFixed(crore % 1 == 0 ? 0 : 1)} Crore';
      } else if (rawPrice >= 100000) {
        final lakh = rawPrice / 100000;
        price = 'PKR ${lakh.toStringAsFixed(lakh % 1 == 0 ? 0 : 1)} Lakh';
      } else {
        price = 'PKR ${rawPrice.toStringAsFixed(0)}';
      }
      if (_propertyData['purpose'] == 'rent') {
        price += '/mo';
      }
    } else {
      price = widget.property['price']?.toString() ?? 'Contact for Price';
    }

    String location = '';
    if (_propertyData['city_name'] != null || _propertyData['location_name'] != null) {
      final String city = _propertyData['city_name']?.toString() ?? '';
      final String locName = _propertyData['location_name']?.toString() ?? '';
      location = locName.isNotEmpty ? '$locName, $city' : city;
    } else {
      location = widget.property['location']?.toString() ?? 'Location, Pakistan';
    }

    final int beds = int.tryParse(_propertyData['beds']?.toString() ?? '') ?? int.tryParse(widget.property['beds']?.toString() ?? '') ?? 0;
    final int baths = int.tryParse(_propertyData['baths']?.toString() ?? '') ?? int.tryParse(widget.property['baths']?.toString() ?? '') ?? 0;

    String area = '';
    if (_propertyData['area_size'] != null) {
      final double rawArea = double.tryParse(_propertyData['area_size']?.toString() ?? '0') ?? 0;
      final String areaUnit = _propertyData['area_unit']?.toString() ?? '';
      final areaSizeStr = rawArea % 1 == 0 ? rawArea.toInt().toString() : rawArea.toStringAsFixed(1);
      area = areaUnit.isNotEmpty ? '$areaSizeStr $areaUnit' : '$areaSizeStr sqft';
    } else {
      area = widget.property['area']?.toString() ?? 'N/A';
    }

    final String premiumType = _propertyData['premium_type']?.toString() ?? '';
    final String premiumStatus = _propertyData['premium_status']?.toString() ?? '';
    final bool isFeatured = _propertyData['is_featured'] == 1 || _propertyData['is_featured'] == true;
    
    String badgeType = 'Regular';
    if (premiumType == 'diamond' && premiumStatus == 'active') {
      badgeType = 'Diamond';
    } else if (premiumType == 'platinum' && premiumStatus == 'active') {
      badgeType = 'Platinum';
    } else if (isFeatured) {
      badgeType = 'Featured';
    } else if (widget.property['badgeType'] != null) {
      badgeType = widget.property['badgeType']?.toString() ?? 'Regular';
    }

    final purpose = _propertyData['purpose']?.toString() == 'rent'
        ? 'Rent'
        : widget.property['purpose']?.toString().toLowerCase() == 'rent'
            ? 'Rent'
            : 'Buy';

    Color badgeColor = AppColors.primary;
    if (badgeType == 'Diamond') {
      badgeColor = AppColors.diamond;
    } else if (badgeType == 'Platinum') {
      badgeColor = AppColors.platinum;
    }

    final description = _propertyData['description']?.toString() ?? 'No description available.';

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
                          _buildCapsuleBadge(purpose.toUpperCase(), AppColors.primaryLight),
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
                      _isLoading
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSkeletonLine(width: double.infinity, height: 13),
                                const SizedBox(height: 8),
                                _buildSkeletonLine(width: double.infinity, height: 13),
                                const SizedBox(height: 8),
                                _buildSkeletonLine(width: 180, height: 13),
                              ],
                            )
                          : Text(
                              description,
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // IMAGE SLIDER
  Widget _buildImageSlider() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Wrap in GestureDetector to give horizontal drag priority over parent scroll
          PageView.builder(
            controller: _pageController,
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
            child: IgnorePointer(
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
            onTap: () async {
              final int pId = int.tryParse(_propertyData['id']?.toString() ?? '') ?? 0;
              // Ensure we include 'image' key so favorite card renders thumbnail correctly
              final savedMap = Map<String, dynamic>.from(_propertyData);
              if (savedMap['image'] == null) {
                savedMap['image'] = _propertyImages.isNotEmpty ? _propertyImages.first : '';
              }
              // Also map area size to area so compact card can read it
              if (savedMap['area'] == null) {
                final double rawArea = double.tryParse(_propertyData['area_size']?.toString() ?? '0') ?? 0;
                final String areaUnit = _propertyData['area_unit']?.toString() ?? '';
                final areaSizeStr = rawArea % 1 == 0 ? rawArea.toInt().toString() : rawArea.toStringAsFixed(1);
                savedMap['area'] = areaUnit.isNotEmpty ? '$areaSizeStr $areaUnit' : '$areaSizeStr sqft';
              }
              // Map location details to location
              if (savedMap['location'] == null) {
                final String city = _propertyData['city_name']?.toString() ?? '';
                final String locName = _propertyData['location_name']?.toString() ?? '';
                savedMap['location'] = locName.isNotEmpty ? '$locName, $city' : city;
              }
              
              await FavoritesManager.toggleFavorite(savedMap);
              final isSavedNow = await FavoritesManager.isFavorite(pId);
              if (mounted) {
                setState(() {
                  _isFavorite = isSavedNow;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFavorite ? 'Added to Favorites!' : 'Removed from Favorites'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
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
    if (_isLoading) {
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
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      );
    }

    final rawAmenities = _propertyData['amenities'] as List<dynamic>? ?? [];

    if (rawAmenities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No amenities specified.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      );
    }

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
      itemCount: rawAmenities.length,
      itemBuilder: (context, index) {
        final item = rawAmenities[index] as Map<String, dynamic>;
        final name = item['label']?.toString() ?? '';
        final val = item['value']?.toString() ?? '';

        IconData icon = Icons.check_circle_outline_rounded;
        final lowerName = name.toLowerCase();
        if (lowerName.contains('gas')) {
          icon = Icons.local_fire_department_rounded;
        } else if (lowerName.contains('electricity')) {
          icon = Icons.flash_on_rounded;
        } else if (lowerName.contains('water')) {
          icon = Icons.water_drop_rounded;
        } else if (lowerName.contains('security')) {
          icon = Icons.security_rounded;
        } else if (lowerName.contains('parking')) {
          icon = Icons.directions_car_rounded;
        } else if (lowerName.contains('wall')) {
          icon = Icons.border_all_rounded;
        }

        final display = val.isNotEmpty && val.toLowerCase() != 'yes' ? '$name ($val)' : name;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryLight, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  display,
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
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonLine(width: 120, height: 14),
                  const SizedBox(height: 8),
                  _buildSkeletonLine(width: 80, height: 11),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final String name = _propertyData['agency_name']?.toString() ?? _propertyData['owner_name']?.toString() ?? 'Landsfy Agent';
    final String subtitle = _propertyData['agency_name'] != null ? 'Registered Agency' : 'Property Owner';
    
    // Avatar url
    String avatar = _propertyData['agency_logo']?.toString() ?? _propertyData['owner_avatar']?.toString() ?? '';
    if (avatar.isNotEmpty && !avatar.startsWith('http://') && !avatar.startsWith('https://')) {
      avatar = 'https://landsfy.com/${avatar.startsWith('/') ? avatar.substring(1) : avatar}';
    }

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
            child: avatar.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatar,
                    height: 52,
                    width: 52,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Container(
                      height: 52,
                      width: 52,
                      color: AppColors.primarySoft,
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  )
                : Container(
                    height: 52,
                    width: 52,
                    color: AppColors.primarySoft,
                    child: const Icon(Icons.person, color: AppColors.primary),
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
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RELATED PROPERTIES SECTION
  Widget _buildRelatedPropertiesSection() {
    if (_isLoading) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
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
                  Container(
                    height: 110,
                    width: 200,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonLine(width: 80, height: 12),
                        const SizedBox(height: 6),
                        _buildSkeletonLine(width: 140, height: 11),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    final List<PropertyModel> relatedList = _similarProperties
        .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
        .toList();

    if (relatedList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'No related properties found.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: relatedList.length,
        itemBuilder: (context, index) {
          final prop = relatedList[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetailsScreen(property: prop.toMap()),
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
                    child: prop.fullThumbnailUrl != null && prop.fullThumbnailUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: prop.fullThumbnailUrl!,
                            height: 110,
                            width: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.bgLight),
                            errorWidget: (context, url, error) => const Icon(Icons.home),
                          )
                        : Container(
                            height: 110,
                            width: 200,
                            color: AppColors.bgLight,
                            child: const Icon(Icons.home),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prop.formattedPrice,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prop.title,
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
                                prop.fullLocation,
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
    final String phone = _propertyData['owner_phone']?.toString() ?? '';
    final String email = _propertyData['owner_email']?.toString() ?? '';
    final String title = _propertyData['title']?.toString() ?? '';

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
            // Email Agent button
            GestureDetector(
              onTap: () => _makeEmail(email, title),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.mail_outline_rounded, color: AppColors.textMain, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Call Agent Button
            Expanded(
              child: GestureDetector(
                onTap: () => _makeCall(phone),
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
            ),
            const SizedBox(width: 12),
            // WhatsApp Button
            Expanded(
              child: GestureDetector(
                onTap: () => _makeWhatsapp(phone, title),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    if (phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch call to $phone');
    }
  }

  Future<void> _makeWhatsapp(String phone, String title) async {
    if (phone.isEmpty) return;
    final String cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final String text = Uri.encodeComponent("Hi, I am interested in your property: $title listed on Landsfy.");
    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=$text");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch WhatsApp for $phone');
    }
  }

  Future<void> _makeEmail(String email, String title) async {
    if (email.isEmpty) return;
    final String subject = Uri.encodeComponent("Inquiry about property: $title");
    final Uri url = Uri.parse("mailto:$email?subject=$subject");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch email to $email');
    }
  }
}


