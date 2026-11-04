/// Represents a user's profile and styling preferences in the EVOQE app.
class UserProfile {
  String name;
  String email;
  String? selfiePath;
  String? selfieGender;
  bool useAvatarInsteadOfPhoto;
  String? gender;
  String? bodyPhotoGender;
  Map<String, String?> bodyPhotoPaths;
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
  bool notifyStyleRecommendations;
  bool notifyLookbookUpdates;
  bool notifyDealAlerts;
  bool notifyWishlistUpdates;
  bool notifyOrderUpdates;

  UserProfile({
    required this.name,
    required this.email,
    this.selfiePath,
    this.selfieGender,
    this.useAvatarInsteadOfPhoto = false,
    this.gender,
    this.bodyPhotoGender,
    Map<String, String?>? bodyPhotoPaths,
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
    bool? notifyStyleRecommendations,
    bool? notifyLookbookUpdates,
    bool? notifyDealAlerts,
    bool? notifyWishlistUpdates,
    bool? notifyOrderUpdates,
  }) : bodyPhotoPaths =
           bodyPhotoPaths ??
           {'front': null, 'left': null, 'right': null, 'back': null},
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
       customPalette = customPalette ?? {},
       notifyStyleRecommendations = notifyStyleRecommendations ?? true,
       notifyLookbookUpdates = notifyLookbookUpdates ?? true,
       notifyDealAlerts = notifyDealAlerts ?? true,
       notifyWishlistUpdates = notifyWishlistUpdates ?? true,
       notifyOrderUpdates = notifyOrderUpdates ?? true;

  /// JSON-safe map (Sets become Lists) for storing in the local database.
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'selfiePath': selfiePath,
    'selfieGender': selfieGender,
    'useAvatarInsteadOfPhoto': useAvatarInsteadOfPhoto,
    'gender': gender,
    'bodyPhotoGender': bodyPhotoGender,
    'bodyPhotoPaths': bodyPhotoPaths,
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
    'notifyStyleRecommendations': notifyStyleRecommendations,
    'notifyLookbookUpdates': notifyLookbookUpdates,
    'notifyDealAlerts': notifyDealAlerts,
    'notifyWishlistUpdates': notifyWishlistUpdates,
    'notifyOrderUpdates': notifyOrderUpdates,
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
      selfieGender: json['selfieGender'] as String?,
      useAvatarInsteadOfPhoto:
          (json['useAvatarInsteadOfPhoto'] as bool?) ?? false,
      gender: json['gender'] as String?,
      bodyPhotoGender: json['bodyPhotoGender'] as String?,
      bodyPhotoPaths: photos,
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
      notifyStyleRecommendations:
          (json['notifyStyleRecommendations'] as bool?) ?? true,
      notifyLookbookUpdates: (json['notifyLookbookUpdates'] as bool?) ?? true,
      notifyDealAlerts: (json['notifyDealAlerts'] as bool?) ?? true,
      notifyWishlistUpdates: (json['notifyWishlistUpdates'] as bool?) ?? true,
      notifyOrderUpdates: (json['notifyOrderUpdates'] as bool?) ?? true,
    );
  }
}
