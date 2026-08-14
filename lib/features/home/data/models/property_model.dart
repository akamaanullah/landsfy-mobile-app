class PropertyModel {
  final int id;
  final String title;
  final String slug;
  final double price;
  final String purpose;
  final double areaSize;
  final String areaUnit;
  final bool isFeatured;
  final String? premiumType;
  final String? premiumStatus;
  final String? priority;
  final String cityName;
  final String? locationName;
  final String? subtypeName;
  final String? categoryName;
  final String? thumbnail;
  final int beds;
  final int baths;
  final bool isSaved;

  PropertyModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.purpose,
    required this.areaSize,
    required this.areaUnit,
    required this.isFeatured,
    this.premiumType,
    this.premiumStatus,
    this.priority,
    required this.cityName,
    this.locationName,
    this.subtypeName,
    this.categoryName,
    this.thumbnail,
    required this.beds,
    required this.baths,
    required this.isSaved,
  });

  String? get fullThumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return null;
    if (thumbnail!.startsWith('http://') || thumbnail!.startsWith('https://')) {
      return thumbnail;
    }
    // Clean leading slash if any
    final cleanPath = thumbnail!.startsWith('/') ? thumbnail!.substring(1) : thumbnail;
    return 'https://landsfy.com/$cleanPath';
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      price: _parseDouble(json['price']),
      purpose: json['purpose']?.toString() ?? 'sell',
      areaSize: _parseDouble(json['area_size']),
      areaUnit: json['area_unit']?.toString() ?? '',
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      premiumType: json['premium_type']?.toString(),
      premiumStatus: json['premium_status']?.toString(),
      priority: json['priority']?.toString(),
      cityName: json['city_name']?.toString() ?? '',
      locationName: json['location_name']?.toString(),
      subtypeName: json['subtype_name']?.toString(),
      categoryName: json['category_name']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      beds: _parseInt(json['beds']),
      baths: _parseInt(json['baths']),
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true,
    );
  }

  /// Formatted price string e.g "PKR 4.8 Crore" or "PKR 1.2 Lakh"
  String get formattedPrice {
    if (price >= 10000000) {
      final crore = price / 10000000;
      return 'PKR ${crore.toStringAsFixed(crore % 1 == 0 ? 0 : 1)} Crore';
    } else if (price >= 100000) {
      final lakh = price / 100000;
      return 'PKR ${lakh.toStringAsFixed(lakh % 1 == 0 ? 0 : 1)} Lakh${purpose == 'rent' ? '/mo' : ''}';
    } else {
      return 'PKR ${price.toStringAsFixed(0)}';
    }
  }

  /// Badge type for UI (Diamond, Platinum, Featured, Regular)
  String get badgeType {
    if (premiumType == 'diamond' && premiumStatus == 'active') return 'Diamond';
    if (premiumType == 'platinum' && premiumStatus == 'active') return 'Platinum';
    if (isFeatured) return 'Featured';
    return 'Regular';
  }

  /// Area display e.g "5 Marla" or "1200 Sq. Ft."
  String get areaDisplay {
    final sizeStr = areaSize % 1 == 0
        ? areaSize.toInt().toString()
        : areaSize.toStringAsFixed(1);
    switch (areaUnit.toLowerCase()) {
      case 'marla': return '$sizeStr Marla';
      case 'kanal': return '$sizeStr Kanal';
      case 'sqft': return '$sizeStr Sq. Ft.';
      case 'sqyrd': return '$sizeStr Sq. Yd.';
      default: return '$sizeStr $areaUnit';
    }
  }

  /// Location display e.g "DHA Phase 6, Karachi"
  String get fullLocation {
    final parts = <String>[];
    if (locationName != null && locationName!.isNotEmpty) parts.add(locationName!);
    if (cityName.isNotEmpty) parts.add(cityName);
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'slug': slug,
    'price': formattedPrice,
    'purpose': purpose == 'sell' ? 'Buy' : 'Rent',
    'area_size': areaSize,
    'area_unit': areaUnit,
    'city_name': cityName,
    'location_name': locationName,
    'subtype_name': subtypeName,
    'thumbnail': fullThumbnailUrl,
    'image': fullThumbnailUrl,
    'location': fullLocation,
    'area': areaDisplay,
    'beds': beds,
    'baths': baths,
    'is_saved': isSaved,
    'badgeType': badgeType,
    'category': categoryName ?? subtypeName ?? '',
  };

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
