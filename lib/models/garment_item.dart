class GarmentItem {
  final String id;
  String name;
  String imagePath;
  String cutoutPath;
  String category; // Tops, Bottoms, Dresses, Outerwear, Shoes, Bags, Accessories, General
  String primaryColor;
  String? secondaryColor;
  String? brand;
  String? season;
  String? occasion;
  List<String> tags;
  bool isFavorite;
  DateTime createdAt;
  String source; // 'live_try_on' | 'digital_closet'

  GarmentItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.cutoutPath,
    required this.category,
    required this.primaryColor,
    this.secondaryColor,
    this.brand,
    this.season,
    this.occasion,
    List<String>? tags,
    this.isFavorite = false,
    DateTime? createdAt,
    required this.source,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'cutoutPath': cutoutPath,
        'category': category,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'brand': brand,
        'season': season,
        'occasion': occasion,
        'tags': tags,
        'isFavorite': isFavorite,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'source': source,
      };

  factory GarmentItem.fromJson(Map<String, dynamic> json) => GarmentItem(
        id: json['id'] as String,
        name: json['name'] as String,
        imagePath: json['imagePath'] as String,
        cutoutPath: json['cutoutPath'] as String,
        category: json['category'] as String? ?? 'General',
        primaryColor: json['primaryColor'] as String? ?? 'Neutral',
        secondaryColor: json['secondaryColor'] as String?,
        brand: json['brand'] as String?,
        season: json['season'] as String?,
        occasion: json['occasion'] as String?,
        tags: (json['tags'] as List?)?.map((t) => t as String).toList() ?? [],
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        source: json['source'] as String? ?? 'digital_closet',
      );
}

class GarmentSegmentationService {
  static Future<String> isolateGarment(String sourceImagePath) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return sourceImagePath;
  }
}

class VirtualTryOnService {
  static Future<bool> performTryOn({
    required String personImagePath,
    required String garmentImagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1800));
    return true;
  }
}
