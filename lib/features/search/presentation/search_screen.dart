import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/search_history_manager.dart';
import '../../home/data/models/property_model.dart';
import '../../properties/data/services/properties_api_service.dart';

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
  String _selectedPurpose = 'All';
  String _selectedCategory = 'All';

  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _popularLocations = [];
  bool _isLoadingCities = true;

  final List<Map<String, String>> _browseCategories = [
    {'label': 'Homes', 'icon': 'home', 'sub': 'Houses, Apartments, Villas'},
    {'label': 'Plots', 'icon': 'location', 'sub': 'Residential, Commercial'},
    {'label': 'Commercial', 'icon': 'business', 'sub': 'Offices, Shops, Warehouses'},
    {'label': 'Farm Houses', 'icon': 'nature', 'sub': 'Farm Houses & Lands'},
  ];

  // API State
  final PropertiesApiService _propertiesApiService = PropertiesApiService();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<PropertyModel> _suggestions = [];

  String _formatPrice(dynamic priceVal, [String purpose = 'sell']) {
    if (priceVal == null) return 'PKR 0';
    final strVal = priceVal.toString().trim();
    if (strVal.startsWith('PKR') || strVal.contains('Crore') || strVal.contains('Lakh') || strVal.contains('Thousand')) {
      return strVal;
    }
    final price = double.tryParse(strVal) ?? 0.0;
    if (price <= 0) return strVal.isEmpty ? 'PKR 0' : strVal;

    if (price >= 10000000) {
      final crore = price / 10000000;
      final formatted = crore.toStringAsFixed(crore % 1 == 0 ? 0 : (crore * 10 % 1 == 0 ? 1 : 2));
      return 'PKR $formatted Crore';
    } else if (price >= 100000) {
      final lakh = price / 100000;
      final formatted = lakh.toStringAsFixed(lakh % 1 == 0 ? 0 : (lakh * 10 % 1 == 0 ? 1 : 2));
      return 'PKR $formatted Lakh${purpose == 'rent' ? '/mo' : ''}';
    } else if (price >= 1000) {
      final thousand = price / 1000;
      final formatted = thousand.toStringAsFixed(thousand % 1 == 0 ? 0 : (thousand * 10 % 1 == 0 ? 1 : 2));
      return 'PKR $formatted Thousand${purpose == 'rent' ? '/mo' : ''}';
    } else {
      return 'PKR ${price.toStringAsFixed(0)}';
    }
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

  String _cityImage(String cityName) {
    switch (cityName.toLowerCase()) {
      case 'karachi': return 'https://images.unsplash.com/photo-1589553416260-f586c8f1514f?auto=format&fit=crop&w=400&q=80';
      case 'lahore': return 'https://images.unsplash.com/photo-1548345680-f5475ea5df84?auto=format&fit=crop&w=400&q=80';
      case 'islamabad': return 'https://images.unsplash.com/photo-1597149268958-9793f7501dd0?auto=format&fit=crop&w=400&q=80';
      case 'rawalpindi': return 'https://images.unsplash.com/photo-1565618754598-3b7bab1edac9?auto=format&fit=crop&w=400&q=80';
      case 'faisalabad': return 'https://images.unsplash.com/photo-1519922639192-e73293ca430e?auto=format&fit=crop&w=400&q=80';
      case 'multan': return 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=400&q=80';
      default: return 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _fetchCities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadRecentSearches() async {
    final list = await SearchHistoryManager.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = list;
      });
    }
  }

  Future<void> _fetchCities() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await dio.get(ApiConstants.appCities);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['cities'] is List) {
          final List cities = data['cities'];
          final List<Map<String, dynamic>> cityList = [];
          for (var c in cities) {
            final name = c['name']?.toString() ?? '';
            final count = c['total_listings']?.toString() ?? '0';
            if (name.isNotEmpty) {
              cityList.add({
                'city': name,
                'listings': count,
                'image': _cityImage(name),
              });
            }
          }
          if (mounted && cityList.isNotEmpty) {
            setState(() {
              _popularLocations = cityList;
              _isLoadingCities = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    // Fallback if network fails
    if (mounted) {
      setState(() {
        _popularLocations = [
          {'city': 'Karachi', 'listings': '12', 'image': _cityImage('Karachi')},
          {'city': 'Lahore', 'listings': '9', 'image': _cityImage('Lahore')},
          {'city': 'Islamabad', 'listings': '6', 'image': _cityImage('Islamabad')},
          {'city': 'Rawalpindi', 'listings': '4', 'image': _cityImage('Rawalpindi')},
          {'city': 'Faisalabad', 'listings': '3', 'image': _cityImage('Faisalabad')},
          {'city': 'Multan', 'listings': '2', 'image': _cityImage('Multan')},
        ];
        _isLoadingCities = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _suggestions.clear();
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        int? catId;
        if (_selectedCategory == 'Homes') catId = 1;
        if (_selectedCategory == 'Plots') catId = 2;
        if (_selectedCategory == 'Commercial') catId = 3;

        final result = await _propertiesApiService.getProperties(
          query: value,
          purpose: _selectedPurpose == 'All' ? null : _selectedPurpose.toLowerCase(),
          categoryId: catId,
        );
        if (mounted) {
          setState(() {
            _suggestions = result['properties'] as List<PropertyModel>;
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  Future<void> _submitSearch(String term) async {
    final cleanTerm = term.trim();
    if (cleanTerm.isEmpty) return;

    await SearchHistoryManager.addSearch(cleanTerm);
    await _loadRecentSearches();

    _searchController.text = cleanTerm;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: cleanTerm.length));
    _onSearchChanged(cleanTerm);
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
                        setState(() {
                          _query = '';
                          _suggestions.clear();
                        });
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
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      if (_query.isNotEmpty) _onSearchChanged(_query);
                    },
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
        children: ['All', 'Buy', 'Rent'].map((p) {
          final isSel = _selectedPurpose == p;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPurpose = p);
              if (_query.isNotEmpty) _onSearchChanged(_query);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
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
        // Dynamic Recent searches
        if (_recentSearches.isNotEmpty) ...[
          _buildSectionHeader('Recent Searches', trailingLabel: 'Clear All', onTrailingTap: () async {
            await SearchHistoryManager.clearHistory();
            setState(() => _recentSearches.clear());
          }),
          ..._recentSearches.map((term) => _buildRecentItem(term)),
          const SizedBox(height: 8),
        ],

        // Browse by category
        _buildSectionHeader('Browse by Category'),
        _buildCategoryGrid(),
        const SizedBox(height: 8),

        // Popular cities (Dynamic database query)
        _buildSectionHeader('Popular Cities'),
        _buildPopularCitiesGrid(),
        const SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
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
            onTap: () async {
              await SearchHistoryManager.removeSearch(term);
              _loadRecentSearches();
            },
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textMuted),
          ),
          onTap: () {
            _submitSearch(term);
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
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
              _submitSearch(cat['label']!);
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
                            fontSize: 12,
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
    if (_isLoadingCities) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
              _submitSearch(loc['city']!);
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

  // ── RESULTS VIEW (when query is typed) ─────────────
  Widget _buildResultsView() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _suggestions.clear();
                    });
                  },
                  child: const Text(
                    'Clear Search',
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
                return _buildResultCard(results[index].toMap());
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
              'No properties found for "$_query"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with a different location, keyword, or price range.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> prop) {
    final int beds = int.tryParse(prop['beds']?.toString() ?? '') ?? 0;
    final int baths = int.tryParse(prop['baths']?.toString() ?? '') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.pushNamed('details', extra: prop);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: prop['thumbnail'] ?? prop['image'] ?? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80',
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                        color: const Color(0xFFE2E8F0)),
                    errorWidget: (ctx, url, e) =>
                        Container(color: const Color(0xFFE2E8F0)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prop['title']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prop['location']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatPrice(prop['price']),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              if (beds > 0) ...[
                                const Icon(Icons.king_bed_outlined,
                                    size: 12,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Text('$beds',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted)),
                                const SizedBox(width: 8),
                              ],
                              if (baths > 0) ...[
                                const Icon(Icons.bathtub_outlined,
                                    size: 12,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Text('$baths',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted)),
                                const SizedBox(width: 8),
                              ],
                              const Icon(Icons.zoom_out_map_rounded,
                                  size: 12,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text((prop['area'] ?? '').toString(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
