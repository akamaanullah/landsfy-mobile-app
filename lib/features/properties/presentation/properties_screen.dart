import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/data/models/property_model.dart';
import '../data/services/properties_api_service.dart';

class PropertiesScreen extends StatefulWidget {
  final Map<String, String>? initialFilters;
  const PropertiesScreen({super.key, this.initialFilters});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final PropertiesApiService _propertiesApiService = PropertiesApiService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // API loading states
  bool _isLoading = true;
  String? _errorMessage;
  List<PropertyModel> _properties = [];
  int _totalProperties = 0;
  int _currentPage = 1;

  // Filter state
  String _selectedPurpose = 'All';
  String _selectedCategory = 'All';
  String _selectedBeds = 'Any';
  String _minPrice = '';
  String _maxPrice = '';
  String _selectedSort = 'newest';

  String get _sortDisplayLabel {
    switch (_selectedSort) {
      case 'price_low':
        return 'Lowest Price First';
      case 'price_high':
        return 'Highest Price First';
      case 'oldest':
        return 'Oldest First';
      case 'newest':
      default:
        return 'Newest First';
    }
  }

  // Active filter count badge
  int get _activeFilterCount {
    int count = 0;
    if (_selectedPurpose != 'All') count++;
    if (_selectedCategory != 'All') count++;
    if (_selectedBeds != 'Any') count++;
    if (_minPrice.isNotEmpty || _maxPrice.isNotEmpty) count++;
    if (_selectedSort != 'newest') count++;
    return count;
  }

  late ScrollController _scrollController;
  bool _isMoreLoading = false;

  Map<String, dynamic> _customQueryParameters = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _applyInitialFilters();
    _loadProperties();
  }

  @override
  void didUpdateWidget(covariant PropertiesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilters != oldWidget.initialFilters) {
      _applyInitialFilters();
      _loadProperties(isRefresh: true);
    }
  }

  void _applyInitialFilters() {
    final filters = widget.initialFilters;
    if (filters != null && filters.isNotEmpty) {
      _customQueryParameters = Map<String, dynamic>.from(filters);
      
      if (filters.containsKey('q')) {
        _searchQuery = filters['q'] ?? '';
        _searchController.text = _searchQuery;
      }
      if (filters.containsKey('purpose')) {
        final p = filters['purpose'];
        if (p != null) {
          if (p.toLowerCase() == 'sell' || p.toLowerCase() == 'buy') {
            _selectedPurpose = 'Buy';
          } else if (p.toLowerCase() == 'rent') {
            _selectedPurpose = 'Rent';
          }
        }
      }
      if (filters.containsKey('category_id') || filters.containsKey('cat_id')) {
        final catId = int.tryParse(filters['category_id'] ?? filters['cat_id'] ?? '');
        if (catId == 1) {
          _selectedCategory = 'Homes';
        } else if (catId == 2) {
          _selectedCategory = 'Plots';
        } else if (catId == 3) {
          _selectedCategory = 'Commercial';
        }
      }
      if (filters.containsKey('min_price')) {
        _minPrice = filters['min_price'] ?? '';
      }
      if (filters.containsKey('max_price')) {
        _maxPrice = filters['max_price'] ?? '';
      }
      if (filters.containsKey('sort')) {
        _selectedSort = filters['sort'] ?? 'newest';
      }
    } else {
      _customQueryParameters.clear();
      _selectedSort = 'newest';
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isMoreLoading && _properties.length < _totalProperties) {
        _currentPage++;
        _loadProperties();
      }
    }
  }

  Future<void> _loadProperties({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _properties.clear();
      });
    }
    try {
      setState(() {
        if (isRefresh || _properties.isEmpty) {
          _isLoading = true;
        } else {
          _isMoreLoading = true;
        }
        _errorMessage = null;
      });

      int? categoryId;
      if (_selectedCategory == 'Homes') categoryId = 1;
      if (_selectedCategory == 'Plots') categoryId = 2;
      if (_selectedCategory == 'Commercial') categoryId = 3;

      double? minPriceVal = double.tryParse(_minPrice);
      double? maxPriceVal = double.tryParse(_maxPrice);

      final Map<String, dynamic> extra = Map<String, dynamic>.from(_customQueryParameters);
      extra.remove('q');
      extra.remove('purpose');
      extra.remove('cat_id');
      extra.remove('category_id');
      extra.remove('min_price');
      extra.remove('max_price');
      extra.remove('page');
      extra.remove('sort');

      final result = await _propertiesApiService.getProperties(
        query: _searchQuery,
        purpose: _selectedPurpose == 'All' ? null : _selectedPurpose,
        categoryId: categoryId,
        minPrice: minPriceVal,
        maxPrice: maxPriceVal,
        sort: _selectedSort,
        page: _currentPage,
        extraParams: extra.isNotEmpty ? extra : null,
      );

      if (mounted) {
        setState(() {
          final List<PropertyModel> newItems = result['properties'] as List<PropertyModel>;
          if (isRefresh) {
            _properties = newItems;
          } else {
            _properties.addAll(newItems);
          }
          _totalProperties = result['total'] as int;
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
                              _loadProperties(isRefresh: true);
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
    final listings = _properties;
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
                    '$_totalProperties Properties Found',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSortModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _sortDisplayLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Listings Grid
            Expanded(
              child: _isLoading && _properties.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : listings.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: listings.length + (listings.length < _totalProperties ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == listings.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
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
                    onSubmitted: (v) => _loadProperties(isRefresh: true),
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
                      _loadProperties(isRefresh: true);
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
        _loadProperties(isRefresh: true);
      }));
    }
    if (_selectedCategory != 'All') {
      chips.add(_buildFilterChip(_selectedCategory, () {
        setState(() => _selectedCategory = 'All');
        _loadProperties(isRefresh: true);
      }));
    }
    if (_selectedBeds != 'Any') {
      chips.add(_buildFilterChip('$_selectedBeds Beds', () {
        setState(() => _selectedBeds = 'Any');
        _loadProperties(isRefresh: true);
      }));
    }
    if (_minPrice.isNotEmpty || _maxPrice.isNotEmpty) {
      chips.add(_buildFilterChip('Price Range', () {
        setState(() {
          _minPrice = '';
          _maxPrice = '';
        });
        _loadProperties(isRefresh: true);
      }));
    }
    if (_selectedSort != 'newest') {
      chips.add(_buildFilterChip('Sort: $_sortDisplayLabel', () {
        setState(() => _selectedSort = 'newest');
        _loadProperties(isRefresh: true);
      }));
    }
    if (_customQueryParameters.containsKey('size')) {
      chips.add(_buildFilterChip('Size: ${_customQueryParameters['size']}', () {
        setState(() => _customQueryParameters.remove('size'));
        _loadProperties(isRefresh: true);
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

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.sort_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Sort Properties By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const Divider(),
              _buildSortOptionTile('Newest First', 'newest', ctx),
              _buildSortOptionTile('Lowest Price First', 'price_low', ctx),
              _buildSortOptionTile('Highest Price First', 'price_high', ctx),
              _buildSortOptionTile('Oldest First', 'oldest', ctx),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptionTile(String label, String sortVal, BuildContext modalCtx) {
    final isSelected = _selectedSort == sortVal;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textMain,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: () {
        Navigator.pop(modalCtx);
        setState(() => _selectedSort = sortVal);
        _loadProperties(isRefresh: true);
      },
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
              _loadProperties(isRefresh: true);
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

  Widget _buildCompactCard(PropertyModel prop) {
    Color badgeColor = AppColors.primary;
    if (prop.badgeType == 'Diamond') badgeColor = AppColors.diamond;
    if (prop.badgeType == 'Platinum') badgeColor = AppColors.platinum;

    return GestureDetector(
      onTap: () => context.pushNamed('details', extra: prop.toMap()),
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
                  child: prop.fullThumbnailUrl != null && prop.fullThumbnailUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: prop.fullThumbnailUrl!,
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
                        )
                      : Container(
                          height: 130,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.home, color: AppColors.border),
                        ),
                ),
                // Badge
                if (prop.badgeType != 'Regular')
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
                        prop.badgeType.toUpperCase(),
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
                      (prop.purpose == 'sell' ? 'BUY' : 'RENT'),
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
                      prop.formattedPrice,
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
                      prop.title,
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
                            prop.fullLocation,
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
                        if (prop.beds > 0) ...[
                          const Icon(Icons.king_bed_outlined, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            '${prop.beds}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (prop.baths > 0) ...[
                          const Icon(Icons.bathtub_outlined, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            '${prop.baths}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const Icon(Icons.zoom_out_map_rounded, size: 11, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            prop.areaDisplay,
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Network error occurred',
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadProperties(isRefresh: true),
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
    );
  }
}
