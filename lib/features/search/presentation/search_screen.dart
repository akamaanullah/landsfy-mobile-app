import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  // Purpose & Category quick filter
  String _selectedPurpose = 'Buy';
  String _selectedCategory = 'All';

  final List<String> _recentSearches = [
    'Apartments in DHA Karachi',
    '5 Marla House Lahore',
    'Commercial Plot Islamabad',
    'Luxury Villa Bahria Town',
  ];

  final List<Map<String, dynamic>> _popularLocations = [
    {'city': 'Karachi', 'listings': '12,400', 'image': 'https://images.unsplash.com/photo-1589553416260-f586c8f1514f?auto=format&fit=crop&w=400&q=80'},
    {'city': 'Lahore', 'listings': '9,210', 'image': 'https://images.unsplash.com/photo-1548345680-f5475ea5df84?auto=format&fit=crop&w=400&q=80'},
    {'city': 'Islamabad', 'listings': '6,890', 'image': 'https://images.unsplash.com/photo-1597149268958-9793f7501dd0?auto=format&fit=crop&w=400&q=80'},
    {'city': 'Rawalpindi', 'listings': '4,120', 'image': 'https://images.unsplash.com/photo-1565618754598-3b7bab1edac9?auto=format&fit=crop&w=400&q=80'},
    {'city': 'Faisalabad', 'listings': '3,540', 'image': 'https://images.unsplash.com/photo-1519922639192-e73293ca430e?auto=format&fit=crop&w=400&q=80'},
    {'city': 'Multan', 'listings': '2,870', 'image': 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=400&q=80'},
  ];

  final List<Map<String, String>> _browseCategories = [
    {'label': 'Homes', 'icon': 'home', 'sub': 'Houses, Apartments, Villas'},
    {'label': 'Plots', 'icon': 'location', 'sub': 'Residential, Commercial'},
    {'label': 'Commercial', 'icon': 'business', 'sub': 'Offices, Shops, Warehouses'},
    {'label': 'Farm Houses', 'icon': 'nature', 'sub': 'Farm Houses & Lands'},
  ];

  final List<Map<String, dynamic>> _allProperties = [
    {
      'title': '240 Sq. Yd. Luxury Villa',
      'location': 'Block A, Naya Nazimabad, Karachi',
      'price': 'PKR 4.8 Crore',
      'beds': 4, 'baths': 5, 'area': '240 Sq. Yd.',
      'badgeType': 'Diamond', 'purpose': 'Buy', 'category': 'Homes',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Premium 3-Bed Apartment',
      'location': 'DHA Phase 6, Karachi',
      'price': 'PKR 2.5 Lakh/mo',
      'beds': 3, 'baths': 3, 'area': '2000 Sq. Ft.',
      'badgeType': 'Platinum', 'purpose': 'Rent', 'category': 'Homes',
      'image': 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': '500 Sq. Yd. Prime Plot',
      'location': 'Bahria Town Phase 2, Lahore',
      'price': 'PKR 3.2 Crore',
      'beds': 0, 'baths': 0, 'area': '500 Sq. Yd.',
      'badgeType': 'Featured', 'purpose': 'Buy', 'category': 'Plots',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Modern Office Suite',
      'location': 'Blue Area, Islamabad',
      'price': 'PKR 1.2 Lakh/mo',
      'beds': 0, 'baths': 2, 'area': '1200 Sq. Ft.',
      'badgeType': 'Regular', 'purpose': 'Rent', 'category': 'Commercial',
      'image': 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': '120 Sq. Yd. Brand New House',
      'location': 'North Karachi, Karachi',
      'price': 'PKR 1.95 Crore',
      'beds': 3, 'baths': 4, 'area': '120 Sq. Yd.',
      'badgeType': 'Regular', 'purpose': 'Buy', 'category': 'Homes',
      'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Penthouse with City View',
      'location': 'Clifton Block 5, Karachi',
      'price': 'PKR 8.5 Crore',
      'beds': 5, 'baths': 6, 'area': '4500 Sq. Ft.',
      'badgeType': 'Diamond', 'purpose': 'Buy', 'category': 'Homes',
      'image': 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=600&q=80',
    },
  ];

  List<Map<String, dynamic>> get _suggestions {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allProperties.where((p) {
      return p['title'].toString().toLowerCase().contains(q) ||
          p['location'].toString().toLowerCase().contains(q) ||
          p['category'].toString().toLowerCase().contains(q);
    }).toList();
  }

  IconData _categoryIcon(String label) {
    switch (label) {
      case 'home': return Icons.home_rounded;
      case 'location': return Icons.location_on_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'nature': return Icons.nature_people_rounded;
      default: return Icons.home_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  void _submitSearch(String term) {
    if (term.trim().isEmpty) return;
    setState(() {
      if (!_recentSearches.contains(term)) {
        _recentSearches.insert(0, term);
        if (_recentSearches.length > 6) _recentSearches.removeLast();
      }
    });
    // Navigate to details if a single result matches exactly
    final match = _allProperties.firstWhere(
      (p) => p['title'].toString().toLowerCase() == term.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );
    if (match.isNotEmpty) {
      context.pushNamed('details', extra: match);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasResults = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Search Bar Header ──
            _buildSearchHeader(),

            // ── Purpose Quick Filters ──
            _buildPurposeBar(),

            // ── Body ──
            Expanded(
              child: hasResults
                  ? _buildResultsView()
                  : _buildDiscoveryView(),
            ),
          ],
        ),
      ),
    );
  }

  // ── SEARCH HEADER ──────────────────────────────────
  Widget _buildSearchHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 14),
      child: Row(
        children: [
          // Back
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.white, size: 20),
          ),
          // Search input
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      onSubmitted: _submitSearch,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.black),
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'City, location, project or keyword...',
                        hintStyle: TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textMuted),
                      ),
                    ),
                  if (_query.isEmpty) const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PURPOSE QUICK FILTER BAR ────────────────────────
  Widget _buildPurposeBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Buy / Rent toggle
          _buildPurposeToggle(),
          const SizedBox(width: 12),
          // Category pills (horizontal scroll)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['All', 'Homes', 'Plots', 'Commercial']
                    .map((cat) {
                  final isSel = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.accent
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSel
                              ? AppColors.black
                              : AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Buy', 'Rent'].map((p) {
          final isSel = _selectedPurpose == p;
          return GestureDetector(
            onTap: () => setState(() => _selectedPurpose = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSel ? AppColors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                p,
                style: TextStyle(
                  color:
                      isSel ? AppColors.primary : AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── DISCOVERY VIEW (empty query) ────────────────────
  Widget _buildDiscoveryView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          _buildSectionHeader('Recent Searches', trailingLabel: 'Clear All', onTrailingTap: () {
            setState(() => _recentSearches.clear());
          }),
          ..._recentSearches.map((term) => _buildRecentItem(term)),
          const SizedBox(height: 8),
        ],

        // Browse by category
        _buildSectionHeader('Browse by Category'),
        _buildCategoryGrid(),
        const SizedBox(height: 8),

        // Popular cities
        _buildSectionHeader('Popular Cities'),
        _buildPopularCitiesGrid(),
        const SizedBox(height: 8),

        // Trending searches
        _buildSectionHeader('Trending Searches'),
        _buildTrendingChips(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader(String title,
      {String? trailingLabel, VoidCallback? onTrailingTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          if (trailingLabel != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String term) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.history_rounded,
            size: 18, color: AppColors.textMuted),
        title: Text(
          term,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain),
        ),
        trailing: GestureDetector(
          onTap: () => setState(() => _recentSearches.remove(term)),
          child: const Icon(Icons.close_rounded,
              size: 16, color: AppColors.textMuted),
        ),
        onTap: () {
          _searchController.text = term;
          setState(() => _query = term);
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: _browseCategories.map((cat) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['label']!;
                _searchController.text = cat['label']!;
                _query = cat['label']!;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _categoryIcon(cat['icon']!),
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['label']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          cat['sub']!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularCitiesGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _popularLocations.length,
        itemBuilder: (context, index) {
          final loc = _popularLocations[index];
          return GestureDetector(
            onTap: () {
              _searchController.text = loc['city']!;
              setState(() => _query = loc['city']!);
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: loc['image']!,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                          color: const Color(0xFFE2E8F0)),
                      errorWidget: (ctx, url, e) =>
                          Container(color: const Color(0xFFE2E8F0)),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Text
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc['city']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${loc['listings']!} listings',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.8),
                              fontSize: 10,
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
        },
      ),
    );
  }

  Widget _buildTrendingChips() {
    final trending = [
      '5 Marla House',
      'DHA Karachi',
      'Bahria Town Lahore',
      '1 Kanal Plot',
      'Apartments Islamabad',
      'Commercial Shops',
      'Farm Houses',
      '3 Bed Apartment',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: trending.map((term) {
          return GestureDetector(
            onTap: () {
              _searchController.text = term;
              setState(() => _query = term);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_rounded,
                      size: 13,
                      color: AppColors.primary.withValues(alpha: 0.7)),
                  const SizedBox(width: 5),
                  Text(
                    term,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── RESULTS VIEW (when query is typed) ─────────────
  Widget _buildResultsView() {
    final results = _suggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count bar
        Container(
          color: AppColors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'} for "$_query"',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              if (results.isNotEmpty)
                GestureDetector(
                  onTap: () => _submitSearch(_query),
                  child: const Text(
                    'See All →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (results.isEmpty)
          _buildNoResults()
        else
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildResultCard(results[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 20),
            Text(
              'No results for "$_query"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try different keywords or check spelling',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Clear Search',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> prop) {
    Color badgeColor = AppColors.primary;
    if (prop['badgeType'] == 'Diamond') badgeColor = AppColors.diamond;
    if (prop['badgeType'] == 'Platinum') badgeColor = AppColors.platinum;

    return GestureDetector(
      onTap: () => context.pushNamed('details', extra: prop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: prop['image'].toString(),
                    width: 110,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) =>
                        Container(width: 110, height: 100, color: const Color(0xFFF1F5F9)),
                    errorWidget: (ctx, url, e) =>
                        Container(width: 110, height: 100, color: const Color(0xFFF1F5F9)),
                  ),
                ),
                if (prop['badgeType'] != 'Regular')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        prop['badgeType'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'For ${prop['purpose']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          prop['category'].toString(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      prop['title'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            prop['location'].toString(),
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prop['price'].toString(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            if (prop['beds'] > 0) ...[
                              const Icon(Icons.king_bed_outlined,
                                  size: 12,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text('${prop['beds']}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                            ],
                            const Icon(Icons.zoom_out_map_rounded,
                                size: 12,
                                color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text(prop['area'].toString(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted)),
                          ],
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
