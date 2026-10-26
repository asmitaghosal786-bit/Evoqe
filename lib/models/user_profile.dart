/// Represents a user's profile and styling preferences in the EVOQE app.
class UserProfile {
  String name;
  String email;
  String? selfiePath;
  bool useAvatarInsteadOfPhoto;
  Map<String, String?> bodyPhotoPaths;
  double? heightCm;
  double? weightKg;
  String? clothingSize;
  String? bustSize;
  String? hipSize;
  String? shoeSize;
  int? skinToneIndex;
  int? undertoneIndex;
  int? fitIndex;
  Set<String> wardrobe;
  Set<String> beauty;
  Set<String> jewelry;
  Set<String> season;
  Set<String> budget;
  Set<String> aesthetics;
  Set<String> palette;
  Set<String> customWardrobe;
  Set<String> customBeauty;
  Set<String> customJewelry;
  Set<String> customSeason;
  Set<String> customBudget;
  Set<String> customAesthetics;
  Set<String> customPalette;

  UserProfile({
    required this.name,
    required this.email,
    this.selfiePath,
    this.useAvatarInsteadOfPhoto = false,
    Map<String, String?>? bodyPhotoPaths,
    this.heightCm,
    this.weightKg,
    this.clothingSize,
    this.bustSize,
    this.hipSize,
    this.shoeSize,
    this.skinToneIndex,
    this.undertoneIndex,
    this.fitIndex,
    Set<String>? wardrobe,
    Set<String>? beauty,
    Set<String>? jewelry,
    Set<String>? season,
    Set<String>? budget,
    Set<String>? aesthetics,
    Set<String>? palette,
    Set<String>? customWardrobe,
    Set<String>? customBeauty,
    Set<String>? customJewelry,
    Set<String>? customSeason,
    Set<String>? customBudget,
    Set<String>? customAesthetics,
    Set<String>? customPalette,
  })  : bodyPhotoPaths = bodyPhotoPaths ??
      {
        'front': null,
        'left': null,
        'right': null,
        'back': null,
      },
        wardrobe = wardrobe ?? {},
        beauty = beauty ?? {},
        jewelry = jewelry ?? {},
        season = season ?? {},
        budget = budget ?? {},
        aesthetics = aesthetics ?? {},
        palette = palette ?? {},
        customWardrobe = customWardrobe ?? {},
        customBeauty = customBeauty ?? {},
        customJewelry = customJewelry ?? {},
        customSeason = customSeason ?? {},
        customBudget = customBudget ?? {},
        customAesthetics = customAesthetics ?? {},
        customPalette = customPalette ?? {};

  /// JSON-safe map (Sets become Lists) for storing in the local database.
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'selfiePath': selfiePath,
    'useAvatarInsteadOfPhoto': useAvatarInsteadOfPhoto,
    'bodyPhotoPaths': bodyPhotoPaths,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'clothingSize': clothingSize,
    'bustSize': bustSize,
    'hipSize': hipSize,
    'shoeSize': shoeSize,
    'skinToneIndex': skinToneIndex,
    'undertoneIndex': undertoneIndex,
    'fitIndex': fitIndex,
    'wardrobe': wardrobe.toList(),
    'beauty': beauty.toList(),
    'jewelry': jewelry.toList(),
    'season': season.toList(),
    'budget': budget.toList(),
    'aesthetics': aesthetics.toList(),
    'palette': palette.toList(),
    'customWardrobe': customWardrobe.toList(),
    'customBeauty': customBeauty.toList(),
    'customJewelry': customJewelry.toList(),
    'customSeason': customSeason.toList(),
    'customBudget': customBudget.toList(),
    'customAesthetics': customAesthetics.toList(),
    'customPalette': customPalette.toList(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Set<String> stringSet(String key) =>
        ((json[key] as List?) ?? const []).map((e) => e as String).toSet();

    // Start from the default four angles so missing keys never break the UI,
    // then overlay whatever was saved.
    final photos = <String, String?>{
      'front': null,
      'left': null,
      'right': null,
      'back': null,
    };
    final savedPhotos = json['bodyPhotoPaths'] as Map?;
    if (savedPhotos != null) {
      savedPhotos.forEach((k, v) => photos[k as String] = v as String?);
    }

    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      selfiePath: json['selfiePath'] as String?,
      useAvatarInsteadOfPhoto:
      (json['useAvatarInsteadOfPhoto'] as bool?) ?? false,
      bodyPhotoPaths: photos,
      // num -> double, because JSON may give back an int (e.g. 170 not 170.0)
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      clothingSize: json['clothingSize'] as String?,
      bustSize: json['bustSize'] as String?,
      hipSize: json['hipSize'] as String?,
      shoeSize: json['shoeSize'] as String?,
      skinToneIndex: json['skinToneIndex'] as int?,
      undertoneIndex: json['undertoneIndex'] as int?,
      fitIndex: json['fitIndex'] as int?,
      wardrobe: stringSet('wardrobe'),
      beauty: stringSet('beauty'),
      jewelry: stringSet('jewelry'),
      season: stringSet('season'),
      budget: stringSet('budget'),
      aesthetics: stringSet('aesthetics'),
      palette: stringSet('palette'),
      customWardrobe: stringSet('customWardrobe'),
      customBeauty: stringSet('customBeauty'),
      customJewelry: stringSet('customJewelry'),
      customSeason: stringSet('customSeason'),
      customBudget: stringSet('customBudget'),
      customAesthetics: stringSet('customAesthetics'),
      customPalette: stringSet('customPalette'),
    );
  }
}