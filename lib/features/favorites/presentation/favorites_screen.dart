import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesManager.getFavorites();
    if (mounted) {
      setState(() {
        _properties = favs;
        _isLoading = false;
      });
    }
  }

  int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

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

  Widget _buildCompactPropertyCard(Map<String, dynamic> prop) {
    Color badgeColor = AppColors.primary;
    if (prop['badgeType'] == 'Diamond') badgeColor = AppColors.diamond;
    if (prop['badgeType'] == 'Platinum') badgeColor = AppColors.platinum;

    final bedsCount = _parseInt(prop['beds']);
    final bathsCount = _parseInt(prop['baths']);

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
                    imageUrl: prop['image']?.toString() ?? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.home_outlined, color: AppColors.border, size: 32),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.home, color: AppColors.border),
                    ),
                  ),
                ),
                // Badge
                if (prop['badgeType'] != null && prop['badgeType'] != 'Regular')
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
                if (prop['purpose'] != null)
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
                // Favorite icon toggle
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      await FavoritesManager.toggleFavorite(prop);
                      _loadFavorites();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPrice(prop['price'], prop['purpose']?.toString() ?? 'sell'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prop['title']?.toString() ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            prop['location']?.toString() ?? '',
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
                        if (bedsCount > 0) ...[
                          const Icon(Icons.king_bed_outlined, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            '$bedsCount',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (bathsCount > 0) ...[
                          const Icon(Icons.bathtub_outlined, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            '$bathsCount',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const Icon(Icons.zoom_out_map_rounded, size: 11, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            (prop['area'] ?? '').toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saved Properties', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _properties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No saved properties yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the heart icon on any listing to save it here.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomScrollView(
                    slivers: [
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildCompactPropertyCard(_properties[index]);
                          },
                          childCount: _properties.length,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
