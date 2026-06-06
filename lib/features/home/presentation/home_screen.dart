import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomNavIndex = 0;
  String _selectedCategory = 'Homes';
  String _selectedSubPill = 'Popular';
  bool _isRentSelected = false;

  final List<String> _subPills = ['Popular', 'Type', 'Area Size'];

  late ScrollController _scrollController;
  double _collapseProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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


  // Mock Property Data
  final List<Map<String, dynamic>> _properties = [
    {
      'title': '240 Sq. Yd. Luxury Villa',
      'location': 'Block A, Naya Nazimabad, Karachi',
      'price': 'PKR 4.8 Crore',
      'beds': 4,
      'baths': 5,
      'area': '240 Sq. Yd.',
      'badgeType': 'Diamond',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80',
      'purpose': 'Buy',
    },
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

  // Mock Blog Data
  final List<Map<String, dynamic>> _blogs = [
    {
      'title': 'Karachi Real Estate Market Trends 2026',
      'category': 'Market Update',
      'image': 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=300&q=80',
      'date': 'June 6, 2026',
      'readTime': '5 min read',
    },
    {
      'title': '5 Tips for First-Time Home Buyers in Pakistan',
      'category': 'Buyer Guide',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=300&q=80',
      'date': 'May 28, 2026',
      'readTime': '4 min read',
    },
    {
      'title': 'Why Naya Nazimabad is a Growing Hub',
      'category': 'Investment',
      'image': 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?auto=format&fit=crop&w=300&q=80',
      'date': 'May 15, 2026',
      'readTime': '7 min read',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            _buildSliverAppBar(),
          ];
        },
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              const SizedBox(height: 100), // Added spacing to prevent bottom bar overlap at end of scroll
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomAppBar(),
      floatingActionButton: _buildGlowingSearchButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                            'Landsfy',
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
              onTap: () => _showSearchBottomSheet(context),
              child: const Text(
                'Search for Homes, Plots...',
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
            onTap: () => _showSearchBottomSheet(context),
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

  // MODAL SEARCH BOTTOM SHEET
  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Properties',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Modal Buy/Rent Toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => _isRentSelected = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isRentSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Buy',
                                style: TextStyle(
                                  color: !_isRentSelected ? AppColors.white : AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => _isRentSelected = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isRentSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Rent',
                                style: TextStyle(
                                  color: _isRentSelected ? AppColors.white : AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Location Input
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Location...',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // City selector dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Karachi',
                        isExpanded: true,
                        items: <String>['Karachi', 'Lahore', 'Islamabad'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category & Beds
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallDropdown('Type', 'Residential'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallDropdown('Beds', '3+'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Price inputs
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallTextField('Price From', 'e.g. 50k'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallTextField('Price To', 'e.g. 2 Crore'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters & Search',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSmallDropdown(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(title, style: const TextStyle(fontSize: 12)),
          style: const TextStyle(fontSize: 12, color: AppColors.textMain),
          items: [value].map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildSmallTextField(String label, String hint) {
    return TextField(
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        hintStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        fillColor: AppColors.white,
        filled: true,
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
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              'Welcome to Landsfy',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.5),
            ),
            accountEmail: const Text('info@landsfy.com'),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const Image(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home_rounded, 'Home', () => Navigator.pop(context)),
                _buildDrawerItem(Icons.add_circle_outline_rounded, 'Add Property', () {}),
                _buildDrawerItem(Icons.search_rounded, 'Search Property', () {}),
                _buildDrawerItem(Icons.new_releases_rounded, 'New Properties', () {}),
                _buildDrawerItem(Icons.favorite_rounded, 'Favorite Properties', () {}),
                _buildDrawerItem(Icons.newspaper_rounded, 'Landsfy News', () {}),
                const Divider(color: AppColors.border, thickness: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(Icons.info_outline_rounded, 'About Us', () {}),
                _buildDrawerItem(Icons.contact_support_outlined, 'Contact Us', () {}),
                _buildDrawerItem(Icons.gavel_rounded, 'Terms & Privacy Policy', () {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '© 2026 Landsfy. All Rights Reserved.',
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

  // CATEGORY BROWSER SECTION
  Widget _buildCategorySection() {
    final subItems = _categoryData[_selectedCategory]?[_selectedSubPill] ?? [];

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
          Row(
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
                    onTap: () {},
                    splashColor: AppColors.primarySoft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
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
    );
  }

  // RECENTLY VIEWED SLIDER
  Widget _buildRecentlyViewedSection() {
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
            itemCount: _properties.length,
            itemBuilder: (context, index) {
              final prop = _properties[index];
              return Container(
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
                      child: CachedNetworkImage(
                        imageUrl: prop['image'],
                        width: 90,
                        height: 130,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.bgLight),
                        errorWidget: (context, url, error) => const Icon(Icons.home),
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
                              prop['title'],
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 10, color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    prop['location'],
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              prop['price'],
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
                      'Post your ad for FREE on Landsfy and connect directly with thousands of verified buyers and renters in Pakistan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
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
            itemCount: _properties.length,
            itemBuilder: (context, index) {
              final prop = _properties[index];
              return _buildPropertyCard(prop);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> prop) {
    Color badgeColor = AppColors.primary;
    if (prop['badgeType'] == 'Diamond') {
      badgeColor = AppColors.diamond;
    } else if (prop['badgeType'] == 'Platinum') {
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
                child: CachedNetworkImage(
                  imageUrl: prop['image'],
                  height: 155,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(height: 155, color: AppColors.bgLight),
                  errorWidget: (context, url, error) => const Icon(Icons.home),
                ),
              ),
              if (prop['badgeType'] != 'Regular')
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
                      prop['badgeType'].toString().toUpperCase(),
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
                    prop['purpose'].toString().toUpperCase(),
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
                  prop['price'],
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  prop['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        prop['location'],
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
                    if (prop['beds'] > 0)
                      _buildSpecItem(Icons.king_bed_outlined, '${prop['beds']} Bed'),
                    if (prop['baths'] > 0)
                      _buildSpecItem(Icons.bathtub_outlined, '${prop['baths']} Bath'),
                    _buildSpecItem(Icons.zoom_out_map, prop['area']),
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
            itemCount: _blogs.length,
            itemBuilder: (context, index) {
              final blog = _blogs[index];
              return Container(
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
                      child: CachedNetworkImage(
                        imageUrl: blog['image'],
                        height: 120,
                        width: 260,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.bgLight),
                        errorWidget: (context, url, error) => const Icon(Icons.newspaper),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog['category'].toString().toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            blog['title'],
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
                                blog['date'],
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              Text(
                                blog['readTime'],
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
        onPressed: () {},
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
      onTap: () => setState(() => _selectedBottomNavIndex = index),
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
