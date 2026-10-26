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
        aesthetics = aesthetics ?? {};
}
