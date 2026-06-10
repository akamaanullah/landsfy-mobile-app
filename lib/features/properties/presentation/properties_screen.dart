import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter state
  String _selectedPurpose = 'All';
  String _selectedCategory = 'All';
  String _selectedBeds = 'Any';
  String _minPrice = '';
  String _maxPrice = '';

  // Active filter count badge
  int get _activeFilterCount {
    int count = 0;
    if (_selectedPurpose != 'All') count++;
    if (_selectedCategory != 'All') count++;
    if (_selectedBeds != 'Any') count++;
    if (_minPrice.isNotEmpty || _maxPrice.isNotEmpty) count++;
    return count;
  }

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
      'category': 'Homes',
    },
    {
      'title': 'Premium 3-Bed Apartment',
      'location': 'DHA Phase 6, Karachi',
      'price': 'PKR 2.5 Lakh/mo',
      'beds': 3,
      'baths': 3,
      'area': '2000 Sq. Ft.',
      'badgeType': 'Platinum',
      'image': 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=600&q=80',
      'purpose': 'Rent',
      'category': 'Homes',
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
      'category': 'Plots',
    },
    {
      'title': 'Modern Office Suite',
      'location': 'Blue Area, Islamabad',
      'price': 'PKR 1.2 Lakh/mo',
      'beds': 0,
      'baths': 2,
      'area': '1200 Sq. Ft.',
      'badgeType': 'Regular',
      'image': 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80',
      'purpose': 'Rent',
      'category': 'Commercial',
    },
    {
      'title': '120 Sq. Yd. Brand New House',
      'location': 'North Karachi, Karachi',
      'price': 'PKR 1.95 Crore',
      'beds': 3,
      'baths': 4,
      'area': '120 Sq. Yd.',
      'badgeType': 'Regular',
      'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=600&q=80',
      'purpose': 'Buy',
      'category': 'Homes',
    },
    {
      'title': 'Penthouse with City View',
      'location': 'Clifton Block 5, Karachi',
      'price': 'PKR 8.5 Crore',
      'beds': 5,
      'baths': 6,
      'area': '4500 Sq. Ft.',
      'badgeType': 'Diamond',
      'image': 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=600&q=80',
      'purpose': 'Buy',
      'category': 'Homes',
    },
  ];

  List<Map<String, dynamic>> get _filteredProperties {
    return _properties.where((prop) {
      final matchesPurpose = _selectedPurpose == 'All' || prop['purpose'] == _selectedPurpose;
      final matchesCategory = _selectedCategory == 'All' || prop['category'] == _selectedCategory;
      final matchesBeds = _selectedBeds == 'Any' ||
          (_selectedBeds == '4+' ? prop['beds'] >= 4 : prop['beds'].toString() == _selectedBeds);
      final matchesSearch = _searchQuery.isEmpty ||
          prop['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prop['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPurpose && matchesCategory && matchesBeds && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterPanel() {
    // Temp state holders inside the sheet
    String tempPurpose = _selectedPurpose;
    String tempCategory = _selectedCategory;
    String tempBeds = _selectedBeds;
    final TextEditingController minCtrl = TextEditingController(text: _minPrice);
    final TextEditingController maxCtrl = TextEditingController(text: _maxPrice);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filters',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempPurpose = 'All';
                                  tempCategory = 'All';
                                  tempBeds = 'Any';
                                  minCtrl.clear();
                                  maxCtrl.clear();
                                });
                              },
                              child: const Text(
                                'Reset All',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      // Scrollable filters
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          children: [
                            // Property Purpose
                            _buildFilterSectionTitle('Property Purpose'),
                            const SizedBox(height: 10),
                            Row(
                              children: ['All', 'Buy', 'Rent'].map((opt) {
                                final isSel = tempPurpose == opt;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () => setSheetState(() => tempPurpose = opt),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppColors.primary : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        opt == 'All' ? 'All' : 'For $opt',
                                        style: TextStyle(
                                          color: isSel ? AppColors.white : AppColors.textMain,
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

                            // Property Category
                            _buildFilterSectionTitle('Property Category'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ['All', 'Homes', 'Plots', 'Commercial'].map((opt) {
                                final isSel = tempCategory == opt;
                                return GestureDetector(
                                  onTap: () => setSheetState(() => tempCategory = opt),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: isSel ? AppColors.primary : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        color: isSel ? AppColors.white : AppColors.textMain,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Bedrooms
                            _buildFilterSectionTitle('Bedrooms'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ['Any', '1', '2', '3', '4+'].map((opt) {
                                final isSel = tempBeds == opt;
                                return GestureDetector(
                                  onTap: () => setSheetState(() => tempBeds = opt),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 56,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isSel ? AppColors.primary : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        color: isSel ? AppColors.white : AppColors.textMain,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Price Range
                            _buildFilterSectionTitle('Price Range (PKR)'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPriceTextField(minCtrl, 'Min (e.g. 50 Lakh)'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildPriceTextField(maxCtrl, 'Max (e.g. 5 Crore)'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                      // Apply button
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedPurpose = tempPurpose;
                                _selectedCategory = tempCategory;
                                _selectedBeds = tempBeds;
                                _minPrice = minCtrl.text;
                                _maxPrice = maxCtrl.text;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
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
      },
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildPriceTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.text,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listings = _filteredProperties;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: Title + Search + Filter button
            _buildTopHeader(),

            // Active filter chips strip
            if (_activeFilterCount > 0) _buildActiveFilterStrip(),

            // Listings count row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${listings.length} Properties Found',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Text(
                    'Sort: Newest First',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Listings Grid
            Expanded(
              child: listings.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        return _buildCompactCard(listings[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Listings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                    ),
              ),
              // Filter button with badge
              GestureDetector(
                onTap: _showFilterPanel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _activeFilterCount > 0 ? AppColors.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: _activeFilterCount > 0 ? AppColors.white : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: _activeFilterCount > 0 ? AppColors.white : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      if (_activeFilterCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$_activeFilterCount',
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 13, color: AppColors.black),
                    decoration: const InputDecoration(
                      hintText: 'Search properties, locations...',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                    ),
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterStrip() {
    final chips = <Widget>[];

    if (_selectedPurpose != 'All') {
      chips.add(_buildFilterChip('For $_selectedPurpose', () {
        setState(() => _selectedPurpose = 'All');
      }));
    }
    if (_selectedCategory != 'All') {
      chips.add(_buildFilterChip(_selectedCategory, () {
        setState(() => _selectedCategory = 'All');
      }));
    }
    if (_selectedBeds != 'Any') {
      chips.add(_buildFilterChip('$_selectedBeds Beds', () {
        setState(() => _selectedBeds = 'Any');
      }));
    }
    if (_minPrice.isNotEmpty || _maxPrice.isNotEmpty) {
      chips.add(_buildFilterChip('Price Range', () {
        setState(() {
          _minPrice = '';
          _maxPrice = '';
        });
      }));
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: chips),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No properties found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPurpose = 'All';
                _selectedCategory = 'All';
                _selectedBeds = 'Any';
                _minPrice = '';
                _maxPrice = '';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Text(
              'Clear all filters',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(Map<String, dynamic> prop) {
    Color badgeColor = AppColors.primary;
    if (prop['badgeType'] == 'Diamond') badgeColor = AppColors.diamond;
    if (prop['badgeType'] == 'Platinum') badgeColor = AppColors.platinum;

    return GestureDetector(
      onTap: () => context.pushNamed('details', extra: prop),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: prop['image'].toString(),
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 130,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.home_outlined, color: AppColors.border, size: 32),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 130,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.home, color: AppColors.border),
                    ),
                  ),
                ),
                // Badge
                if (prop['badgeType'] != 'Regular')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        prop['badgeType'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                // Purpose
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prop['purpose'].toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Favorite icon
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price
                    Text(
                      prop['price'].toString(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Title
                    Text(
                      prop['title'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textMain,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 10, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            prop['location'].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Specs row
                    Row(
                      children: [
                        if (prop['beds'] > 0) ...[
                          const Icon(Icons.king_bed_outlined, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            '${prop['beds']}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (prop['baths'] > 0) ...[
                          const Icon(Icons.bathtub_outlined, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            '${prop['baths']}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const Icon(Icons.zoom_out_map_rounded, size: 11, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            prop['area'].toString(),
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
