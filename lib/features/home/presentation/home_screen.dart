import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../data/models/property_model.dart';
import '../data/models/blog_model.dart';
import '../data/services/home_api_service.dart';
import '../../properties/presentation/properties_screen.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/data/services/auth_api_service.dart';
import '../../profile/presentation/screens/add_property_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, String>? initialFilters;
  const HomeScreen({super.key, this.initialFilters});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomNavIndex = 0;
  Map<String, String>? _activeFilters;
  String _selectedCategory = 'Homes';
  String _selectedSubPill = 'Popular';
  bool _isRentSelected = false;

  final List<String> _subPills = ['Popular', 'Type', 'Area Size'];

  late ScrollController _scrollController;
  double _collapseProgress = 0.0;

  // API state
  final HomeApiService _apiService = HomeApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<PropertyModel> _featuredProperties = [];
  List<BlogModel> _latestBlogs = [];
  Map<String, dynamic> _browseData = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    if (widget.initialFilters != null && widget.initialFilters!.isNotEmpty) {
      if (widget.initialFilters!.containsKey('tab')) {
        _selectedBottomNavIndex = int.tryParse(widget.initialFilters!['tab'] ?? '0') ?? 0;
        _activeFilters = null;
      } else {
        _selectedBottomNavIndex = 1;
        _activeFilters = widget.initialFilters;
      }
    }
    _loadHomeData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilters != oldWidget.initialFilters &&
        widget.initialFilters != null &&
        widget.initialFilters!.isNotEmpty) {
      setState(() {
        if (widget.initialFilters!.containsKey('tab')) {
          _selectedBottomNavIndex = int.tryParse(widget.initialFilters!['tab'] ?? '0') ?? 0;
          _activeFilters = null;
        } else {
          _selectedBottomNavIndex = 1;
          _activeFilters = widget.initialFilters;
        }
      });
    }
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await _apiService.getHomeData();
      if (mounted) {
        setState(() {
          _featuredProperties = data.featuredProperties;
          _latestBlogs = data.latestBlogs;
          _browseData = data.browseData;
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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      // 160.0 is the collapsible height (220.0 expandedHeight - 60.0 bottomHeight)
      final progress = (offset / 160.0).clamp(0.0, 1.0);
      if (progress != _collapseProgress) {
        setState(() {
          _collapseProgress = progress;
        });
      }
    }
  }

  final Map<String, Map<String, List<Map<String, dynamic>>>> _categoryData = {
    'Homes': {
      'Popular': [
        {'name': 'Apartments', 'icon': Icons.apartment_rounded},
        {'name': 'Bungalows', 'icon': Icons.home_rounded},
        {'name': 'Luxury Villas', 'icon': Icons.cottage_rounded},
        {'name': 'Penthouses', 'icon': Icons.domain_rounded},
        {'name': 'Portions', 'icon': Icons.layers_rounded},
        {'name': 'Farm Houses', 'icon': Icons.agriculture_rounded},
      ],
      'Type': [
        {'name': '1 Bedroom', 'icon': Icons.king_bed_rounded},
        {'name': '2 Bedrooms', 'icon': Icons.hotel_rounded},
        {'name': '3 Bedrooms', 'icon': Icons.bed_rounded},
        {'name': '4 Bedrooms', 'icon': Icons.meeting_room_rounded},
        {'name': 'Studio Flat', 'icon': Icons.single_bed_rounded},
        {'name': 'Duplex House', 'icon': Icons.house_siding_rounded},
      ],
      'Area Size': [
        {'name': '5 Marla', 'icon': Icons.straighten_rounded},
        {'name': '10 Marla', 'icon': Icons.photo_size_select_small_rounded},
        {'name': '1 Kanal', 'icon': Icons.landscape_rounded},
        {'name': '120 Sq. Yd.', 'icon': Icons.grid_view_rounded},
        {'name': '240 Sq. Yd.', 'icon': Icons.view_quilt_rounded},
        {'name': '500 Sq. Yd.', 'icon': Icons.view_comfy_rounded},
      ],
    },
    'Plots': {
      'Popular': [
        {'name': 'Residential', 'icon': Icons.location_city_rounded},
        {'name': 'Commercial', 'icon': Icons.storefront_rounded},
        {'name': 'Agricultural', 'icon': Icons.grass_rounded},
        {'name': 'Industrial', 'icon': Icons.factory_rounded},
        {'name': 'Plot Files', 'icon': Icons.description_rounded},
        {'name': 'Farm Plots', 'icon': Icons.nature_people_rounded},
      ],
      'Type': [
        {'name': 'Corner Plot', 'icon': Icons.turn_right_rounded},
        {'name': 'Park Facing', 'icon': Icons.park_rounded},
        {'name': 'Main Boulevard', 'icon': Icons.add_road_rounded},
        {'name': 'Boundary Wall', 'icon': Icons.border_all_rounded},
        {'name': 'Sewerage Done', 'icon': Icons.water_drop_rounded},
        {'name': 'Electricity', 'icon': Icons.power_rounded},
      ],
      'Area Size': [
        {'name': '5 Marla Plots', 'icon': Icons.straighten_rounded},
        {'name': '10 Marla Plots', 'icon': Icons.photo_size_select_small_rounded},
        {'name': '1 Kanal Plots', 'icon': Icons.landscape_rounded},
        {'name': '120 Sq. Yd.', 'icon': Icons.grid_view_rounded},
        {'name': '240 Sq. Yd.', 'icon': Icons.view_quilt_rounded},
        {'name': '500 Sq. Yd.', 'icon': Icons.view_comfy_rounded},
      ],
    },
    'Commercial': {
      'Popular': [
        {'name': 'Small Offices', 'icon': Icons.desktop_mac_rounded},
        {'name': 'New Offices', 'icon': Icons.work_rounded},
        {'name': 'On Instalments', 'icon': Icons.credit_card_rounded},
        {'name': 'Small Shops', 'icon': Icons.shopping_bag_rounded},
        {'name': 'New Shops', 'icon': Icons.new_releases_rounded},
        {'name': 'Running Shops', 'icon': Icons.storefront_rounded},
      ],
      'Type': [
        {'name': 'Offices', 'icon': Icons.domain_rounded},
        {'name': 'Shops', 'icon': Icons.store_rounded},
        {'name': 'Warehouses', 'icon': Icons.warehouse_rounded},
        {'name': 'Buildings', 'icon': Icons.business_rounded},
        {'name': 'Factories', 'icon': Icons.precision_manufacturing_rounded},
        {'name': 'Showrooms', 'icon': Icons.palette_rounded},
      ],
      'Area Size': [
        {'name': 'Under 500 Sq. Ft.', 'icon': Icons.crop_square_rounded},
        {'name': '500-1000 Sq. Ft.', 'icon': Icons.aspect_ratio_rounded},
        {'name': '1000-2000 Sq. Ft.', 'icon': Icons.grid_on_rounded},
        {'name': '2000-5000 Sq. Ft.', 'icon': Icons.zoom_in_map_rounded},
        {'name': 'Above 5000 Sq. Ft.', 'icon': Icons.fit_screen_rounded},
        {'name': 'Commercial Plots', 'icon': Icons.pin_drop_rounded},
      ],
    },
  };


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastBackPressTime;

  // Live data loaded from API (see _loadHomeData)

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. If Drawer is open, close drawer
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeDrawer();
          return;
        }

        // 2. If on non-Home tab (Properties, Favorites, Profile) or active filters, return to Home Tab
        if (_selectedBottomNavIndex != 0 || _activeFilters != null) {
          setState(() {
            _selectedBottomNavIndex = 0;
            _activeFilters = null;
          });
          return;
        }

        // 3. Double tap within 2 seconds to exit app
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit landsfy.com'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildSideDrawer(),
        body: _buildBody(),
        bottomNavigationBar: _buildCustomBottomAppBar(),
        floatingActionButton: isKeyboardOpen ? null : _buildGlowingSearchButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedBottomNavIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return PropertiesScreen(initialFilters: _activeFilters);
      case 2:
        return const FavoritesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  Widget _buildHomeBody() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCategorySection(),
              const SizedBox(height: 28),
              _buildRecentlyViewedSection(),
              const SizedBox(height: 28),
              _buildCTABannerSection(),
              const SizedBox(height: 28),
              _buildFeaturedPropertiesSection(),
              const SizedBox(height: 28),
              _buildBlogsSection(),
              const SizedBox(height: 100), // Spacing to prevent bottom bar overlap
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 220.0,
      toolbarHeight: 12.0, // Adds a small purple spacer under the status bar when collapsed
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false, // hide default hamburger menu
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/header_bg.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppColors.primary.withValues(alpha: 0.4),
                BlendMode.srcOver,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false, // Only safe area top to prevent overlapping status bar
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Menu drawer button and brand text centered - fades out on collapse
                  IgnorePointer(
                    ignoring: _collapseProgress > 0.5,
                    child: Opacity(
                      opacity: (1.0 - _collapseProgress).clamp(0.0, 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu_rounded, color: AppColors.white, size: 28),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          Text(
                            'LANDSFY',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  letterSpacing: 1.0,
                                ),
                          ),
                          const SizedBox(width: 48), // Spacer to balance the leading menu button
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Buy / Rent Toggle
                  _buildHeroBuyRentToggle(),
                  const SizedBox(height: 68), // Ensures perfect spacing above search bar (60px bottom height + gap)
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              IgnorePointer(
                ignoring: _collapseProgress < 0.5,
                child: AnimatedContainer(
                  duration: Duration.zero,
                  width: 40.0 * _collapseProgress,
                  height: 40.0,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: OverflowBox(
                    minWidth: 0,
                    maxWidth: 40,
                    minHeight: 0,
                    maxHeight: 40,
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: _collapseProgress,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded, color: AppColors.white, size: 26),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildStickySearchBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STICKY SEARCH BAR (Always pinned at the top when collapsed)
  Widget _buildStickySearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => context.pushNamed('search'),
              child: const Text(
                'Search for Homes, Plots...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: AppColors.border,
          ),
          GestureDetector(
            onTap: () => context.pushNamed('search'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Karachi',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeroBuyRentToggle() {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRentSelected = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: !_isRentSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      color: !_isRentSelected ? AppColors.primary : AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRentSelected = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: _isRentSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Rent',
                    style: TextStyle(
                      color: _isRentSelected ? AppColors.primary : AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SIDE DRAWER
  Widget _buildSideDrawer() {
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: AuthApiService.getUserSession(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final bool isLoggedIn = user != null;
              final String name = isLoggedIn
                  ? (user['full_name']?.toString().isNotEmpty == true
                      ? user['full_name'].toString()
                      : (user['username']?.toString() ?? 'User'))
                  : 'Welcome to LANDSFY';
              final String email = isLoggedIn
                  ? (user['email']?.toString() ?? user['role']?.toString().toUpperCase() ?? '')
                  : 'Sign in to post & manage properties';

              String? avatarUrl = user?['avatar_url']?.toString();
              if (avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
                avatarUrl = '${ApiConstants.baseUrl}/${avatarUrl.startsWith('/') ? avatarUrl.substring(1) : avatarUrl}';
              }

              final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.3),
                ),
                accountEmail: Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                currentAccountPicture: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 22),
                                ),
                              ),
                            ),
                            errorWidget: (ctx, url, err) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 22),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            child: Center(
                              child: isLoggedIn
                                  ? Text(
                                      initial,
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 24),
                                    )
                                  : const Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home_rounded, 'Home', () => Navigator.pop(context)),
                _buildDrawerItem(Icons.add_circle_outline_rounded, 'Add Property', () async {
                  Navigator.pop(context);
                  final userSession = await AuthApiService.getUserSession();
                  if (!mounted) return;
                  if (userSession != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPropertyScreen(userSession: userSession)),
                    );
                  } else {
                    setState(() {
                      _selectedBottomNavIndex = 3;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please sign in to add a property listing')),
                    );
                  }
                }),
                _buildDrawerItem(Icons.search_rounded, 'Search Property', () {
                  Navigator.pop(context);
                  context.pushNamed('search');
                }),
                _buildDrawerItem(Icons.new_releases_rounded, 'New Properties', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedBottomNavIndex = 1;
                    _activeFilters = {'sort': 'newest'};
                  });
                }),
                _buildDrawerItem(Icons.favorite_rounded, 'Favorite Properties', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedBottomNavIndex = 2;
                    _activeFilters = null;
                  });
                }),
                _buildDrawerItem(Icons.newspaper_rounded, 'LANDSFY News', () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedBottomNavIndex = 0;
                  });
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      1100.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  }
                }),
                const Divider(color: AppColors.border, thickness: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(Icons.info_outline_rounded, 'About Us', () {
                  Navigator.pop(context);
                  _showAboutUsSheet(context);
                }),
                _buildDrawerItem(Icons.contact_support_outlined, 'Contact Us', () {
                  Navigator.pop(context);
                  _showContactUsSheet(context);
                }),
                _buildDrawerItem(Icons.gavel_rounded, 'Terms & Privacy Policy', () {
                  Navigator.pop(context);
                  _showTermsPrivacySheet(context);
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '© 2026 LANDSFY. All Rights Reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutUsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LANDSFY Real Estate',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textMain),
                        ),
                        Text(
                          'Version 1.0.0 (Native App)',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'About Us',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'LANDSFY is Pakistan\'s premier digital real estate platform designed to empower property buyers, sellers, real estate agents, and agency owners with verified listings and seamless discovery.',
                  style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Core Capabilities:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                ),
                const SizedBox(height: 10),
                _buildAboutFeatureTile(Icons.verified_user_rounded, 'Verified Listings', 'All property submissions undergo strict admin moderation.'),
                _buildAboutFeatureTile(Icons.handshake_rounded, 'Direct Agent Connect', 'Connect instantly with certified agents via Phone or WhatsApp.'),
                _buildAboutFeatureTile(Icons.filter_alt_rounded, 'Smart Filter Engine', 'Search by city, property category, price range, and area size.'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutFeatureTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactUsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Contact Support & Inquiries',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textMain),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We are here to assist you 24/7 with any property or account questions.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                _buildContactCard(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'Helpline Number',
                  value: '+92 (21) 111-526-373',
                  actionLabel: 'Call Now',
                  onTap: () async {
                    final uri = Uri.parse('tel:+9221111526373');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.email_rounded,
                  title: 'Email Address',
                  value: 'info@landsfy.com',
                  actionLabel: 'Send Mail',
                  onTap: () async {
                    final uri = Uri.parse('mailto:info@landsfy.com');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.location_on_rounded,
                  title: 'Head Office Address',
                  value: 'LANDSFY Tower, Main Boulevard, DHA Phase 6, Karachi',
                  actionLabel: '',
                  onTap: null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required String actionLabel,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              ],
            ),
          ),
          if (actionLabel.isNotEmpty && onTap != null) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  void _showTermsPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Terms & Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textMain),
              ),
              const SizedBox(height: 4),
              const Text('Last updated: August 2026', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('1. Terms of Service', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                      SizedBox(height: 8),
                      Text(
                        'By using the LANDSFY mobile application, you agree to comply with our listing policies. All listings submitted by agents, sellers, or agencies must contain accurate property information, valid pricing, and real images.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain),
                      ),
                      SizedBox(height: 16),
                      Text('2. User & Agent Verification', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                      SizedBox(height: 8),
                      Text(
                        'Agencies and Agents operating on LANDSFY are subject to identity and agency verification by system administrators to maintain platform trust.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain),
                      ),
                      SizedBox(height: 16),
                      Text('3. Privacy & Data Security', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                      SizedBox(height: 8),
                      Text(
                        'Your personal data, login credentials, and saved preferences are stored using secure encryption protocol. LANDSFY does not share user contact details with third-party advertisers.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain),
                      ),
                      SizedBox(height: 16),
                      Text('4. Contacting Sellers & Agents', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                      SizedBox(height: 8),
                      Text(
                        'Interactions between buyers and agents initiated through Phone or WhatsApp are conducted directly between the involved parties.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMain),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('I Understand', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.textMain,
            ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }

  IconData _getBrowseIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('apartment') || n.contains('flat') || n.contains('penthouse')) return Icons.apartment_rounded;
    if (n.contains('house') || n.contains('bungalow') || n.contains('villa')) return Icons.home_rounded;
    if (n.contains('portion')) return Icons.layers_rounded;
    if (n.contains('farm')) return Icons.agriculture_rounded;
    if (n.contains('residential') || n.contains('corner')) return Icons.location_city_rounded;
    if (n.contains('commercial') || n.contains('shop') || n.contains('showroom')) return Icons.storefront_rounded;
    if (n.contains('agricultural') || n.contains('land')) return Icons.grass_rounded;
    if (n.contains('industrial') || n.contains('factory')) return Icons.factory_rounded;
    if (n.contains('file')) return Icons.description_rounded;
    if (n.contains('office') || n.contains('work')) return Icons.work_rounded;
    if (n.contains('instalment')) return Icons.credit_card_rounded;
    if (n.contains('warehouse')) return Icons.warehouse_rounded;
    if (n.contains('building')) return Icons.business_rounded;
    if (n.contains('marla') || n.contains('kanal') || n.contains('sqft') || n.contains('sq. ft') || n.contains('sqyrd') || n.contains('sq. yd') || n.contains('size') || n.contains('area')) {
      return Icons.straighten_rounded;
    }
    return Icons.label_important_rounded;
  }

  List<Map<String, dynamic>> _getBrowseItems() {
    if (_browseData.isEmpty) {
      final mockList = _categoryData[_selectedCategory]?[_selectedSubPill] ?? [];
      return mockList;
    }

    final String catKey = _selectedCategory == 'Homes'
        ? 'home'
        : _selectedCategory == 'Plots'
            ? 'plots'
            : 'commercial';
    final String subKey = _selectedSubPill == 'Popular'
        ? 'popular'
        : _selectedSubPill == 'Type'
            ? 'types'
            : 'sizes';

    final rawList = _browseData[catKey]?[subKey] as List<dynamic>? ?? [];
    return rawList.map((item) {
      final String name = item['name']?.toString() ?? '';
      return {
        'name': name,
        'query': item['query']?.toString() ?? (item['id'] != null ? 'category_id=${catKey == 'home' ? 1 : catKey == 'plots' ? 2 : 3}&subtype_id=${item['id']}' : ''),
        'id': item['id'],
        'icon': _getBrowseIcon(name),
      };
    }).toList();
  }

  // CATEGORY BROWSER SECTION
  Widget _buildCategorySection() {
    final subItems = _getBrowseItems();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Properties',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: -0.5,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 16),

          // Main Tabs (Homes, Plots, Commercial)
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                _buildMainCategoryTab('Homes', Icons.home_rounded),
                _buildMainCategoryTab('Plots', Icons.location_on_rounded),
                _buildMainCategoryTab('Commercial', Icons.business_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sub-pills (Popular, Type, Area Size)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _subPills.map((pill) {
                final isSelected = _selectedSubPill == pill;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSubPill = pill),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primarySoft : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pill,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Sub-items Grid (2-column layout)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: subItems.length,
            itemBuilder: (context, index) {
              final item = subItems[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _handleBrowseItemTap(item),
                    splashColor: AppColors.primarySoft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData? ?? Icons.label_important_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['name'].toString(),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleBrowseItemTap(Map<String, dynamic> item) {
    final int catId = _selectedCategory == 'Homes' ? 1 : _selectedCategory == 'Plots' ? 2 : 3;
    final Map<String, String> filters = {
      'cat_id': '$catId',
      'category_id': '$catId',
    };

    final String queryStr = item['query']?.toString() ?? '';
    if (queryStr.isNotEmpty) {
      final parsed = Uri.parse('?$queryStr').queryParameters;
      filters.addAll(parsed);
    } else {
      final String name = (item['name']?.toString() ?? '').toLowerCase();
      if (name.contains('low price') || name.contains('lowest')) {
        filters['sort'] = 'price_low';
      } else if (name == 'new' || name.contains('newest') || name.contains('new ')) {
        filters['sort'] = 'newest';
      } else if (name.contains('5 marla')) {
        filters['size'] = '5-marla';
      } else if (name.contains('10 marla')) {
        filters['size'] = '10-marla';
      } else if (name.contains('3 marla') || name == 'small') {
        filters['size'] = '3-marla';
      } else if (name.contains('7 marla')) {
        filters['size'] = '7-marla';
      } else if (name.contains('8 marla')) {
        filters['size'] = '8-marla';
      } else if (name.contains('1 kanal')) {
        filters['size'] = '1-kanal';
      } else if (name.contains('120 sq')) {
        filters['size'] = '120-sq-yd';
      } else if (name.contains('240 sq')) {
        filters['size'] = '240-sq-yd';
      } else if (name.contains('500 sq')) {
        filters['size'] = '500-sq-yd';
      } else if (name.contains('apartment') || name.contains('flat')) {
        filters['type_id'] = '2';
        filters['subtype_id'] = '2';
      } else if (name.contains('house') || name.contains('bungalow') || name.contains('villa')) {
        filters['type_id'] = '1';
        filters['subtype_id'] = '1';
      } else if (name.contains('penthouse')) {
        filters['type_id'] = '7';
        filters['subtype_id'] = '7';
      } else if (name.contains('portion')) {
        filters['type_id'] = '3';
        filters['subtype_id'] = '3';
      } else if (name.contains('residential')) {
        filters['type_id'] = '8';
        filters['subtype_id'] = '8';
      } else if (name.contains('commercial')) {
        filters['type_id'] = '9';
        filters['subtype_id'] = '9';
      } else if (name.contains('agricultural')) {
        filters['type_id'] = '10';
        filters['subtype_id'] = '10';
      } else if (name.contains('industrial')) {
        filters['type_id'] = '11';
        filters['subtype_id'] = '11';
      } else if (name.contains('office')) {
        filters['type_id'] = '12';
        filters['subtype_id'] = '12';
      } else if (name.contains('shop')) {
        filters['type_id'] = '13';
        filters['subtype_id'] = '13';
      }
    }

    if (item['id'] != null) {
      filters['type_id'] = item['id'].toString();
      filters['subtype_id'] = item['id'].toString();
    }

    setState(() {
      _selectedBottomNavIndex = 1;
      _activeFilters = filters;
    });
  }

  Widget _buildMainCategoryTab(String categoryName, IconData icon) {
    final isSelected = _selectedCategory == categoryName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCategory = categoryName;
          _selectedSubPill = 'Popular';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  categoryName,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // RECENTLY VIEWED SLIDER
  Widget _buildRecentlyViewedSection() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Recently Viewed', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 10),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (_featuredProperties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recently Viewed',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: -0.5,
                  fontSize: 20,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 10),
            itemCount: _featuredProperties.length,
            itemBuilder: (context, index) {
              final prop = _featuredProperties[index];
              return GestureDetector(
                onTap: () => context.pushNamed('details', extra: prop.toMap()),
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: prop.fullThumbnailUrl != null && prop.fullThumbnailUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: prop.fullThumbnailUrl!,
                                width: 90,
                                height: 130,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: AppColors.bgLight),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.bgLight,
                                  child: const Icon(Icons.home, color: AppColors.primary),
                                ),
                              )
                            : Container(
                                width: 90,
                                height: 130,
                                color: AppColors.bgLight,
                                child: const Icon(Icons.home, color: AppColors.primary),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                prop.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 10, color: AppColors.textMuted),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      prop.fullLocation,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                prop.formattedPrice,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // CTA CONTENT BANNER (SELL OR RENT YOUR PROPERTY)
  Widget _buildCTABannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SELL OR RENT',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Looking to sell or rent out your property?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Post your ad for FREE on LANDSFY and connect directly with thousands of verified buyers and renters in Pakistan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final userSession = await AuthApiService.getUserSession();
                        if (!mounted) return;
                        if (userSession != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddPropertyScreen(userSession: userSession)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please sign in to post a property listing')),
                          );
                          setState(() {
                            _selectedBottomNavIndex = 3;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                      label: const Text(
                        'Post an Ad Now',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  // FEATURED PROPERTIES SECTION
  Widget _buildFeaturedPropertiesSection() {
    // Loading skeleton
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Featured Properties', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 375,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 4),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          ),
        ],
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Column(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 36),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _loadHomeData,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (_featuredProperties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Properties',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: -0.5,
                      fontSize: 20,
                    ),
              ),
              Text(
                'Browse More',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 375,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 4),
            itemCount: _featuredProperties.length,
            itemBuilder: (context, index) {
              final prop = _featuredProperties[index];
              return GestureDetector(
                onTap: () => context.pushNamed('details', extra: prop.toMap()),
                child: _buildPropertyCard(prop),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(PropertyModel prop) {
    Color badgeColor = AppColors.primary;
    if (prop.badgeType == 'Diamond') {
      badgeColor = AppColors.diamond;
    } else if (prop.badgeType == 'Platinum') {
      badgeColor = AppColors.platinum;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: prop.fullThumbnailUrl != null && prop.fullThumbnailUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: prop.fullThumbnailUrl!,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(height: 155, color: AppColors.bgLight),
                        errorWidget: (context, url, error) => Container(
                          height: 155,
                          color: AppColors.bgLight,
                          child: const Icon(Icons.home_rounded, size: 48, color: AppColors.primary),
                        ),
                      )
                    : Container(
                        height: 155,
                        width: double.infinity,
                        color: AppColors.bgLight,
                        child: const Icon(Icons.home_rounded, size: 48, color: AppColors.primary),
                      ),
              ),
              if (prop.badgeType != 'Regular')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prop.badgeType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (prop.purpose == 'sell' ? 'BUY' : 'RENT'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prop.formattedPrice,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  prop.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        prop.fullLocation,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (prop.beds > 0)
                      _buildSpecItem(Icons.king_bed_outlined, '${prop.beds} Bed'),
                    if (prop.baths > 0)
                      _buildSpecItem(Icons.bathtub_outlined, '${prop.baths} Bath'),
                    _buildSpecItem(Icons.zoom_out_map, prop.areaDisplay),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // BLOGS SECTION (LATEST NEWS & INSIGHTS)
  Widget _buildBlogsSection() {
    if (_isLoading || _latestBlogs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest News & Insights',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: -0.5,
                      fontSize: 20,
                    ),
              ),
              Text(
                'Read All',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 10),
            itemCount: _latestBlogs.length,
            itemBuilder: (context, index) {
              final blog = _latestBlogs[index];
              return GestureDetector(
                onTap: () => context.pushNamed('blog_detail', pathParameters: {'slug': blog.slug}),
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: blog.fullImageUrl != null && blog.fullImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: blog.fullImageUrl!,
                                height: 120,
                                width: 260,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(height: 120, color: AppColors.bgLight),
                                errorWidget: (context, url, error) => Container(
                                  height: 120,
                                  color: AppColors.bgLight,
                                  child: const Icon(Icons.newspaper, size: 36, color: AppColors.primary),
                                ),
                              )
                            : Container(
                                height: 120,
                                color: AppColors.bgLight,
                                child: const Icon(Icons.newspaper, size: 36, color: AppColors.primary),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              blog.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.black,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  blog.formattedDate,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                                const Text(
                                  'Read More →',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w600,
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
        ),
      ],
    );
  }

  // GLOWING SEARCH BUTTON (FAB)
  Widget _buildGlowingSearchButton() {
    return Container(
      height: 62,
      width: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => context.pushNamed('search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // CUSTOM BOTTOM APP BAR
  Widget _buildCustomBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.white,
      elevation: 12,
      child: Container(
        height: 60,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                  _buildBottomNavItem(1, Icons.business_center_rounded, Icons.business_center_outlined, 'Properties'),
                ],
              ),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem(2, Icons.favorite_rounded, Icons.favorite_outline_rounded, 'Favorites'),
                  _buildBottomNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
          _activeFilters = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
