import 'package:flutter/foundation.dart';

import '../data/local_db/session_store.dart';
import '../models/user_profile.dart';
import '../models/lookbook_model.dart';
import '../models/garment_item.dart';
import '../models/personal_collection.dart';
import '../models/saved_outfit.dart';
import '../services/auth_service.dart';

class SavedLook {
  final String id;
  final String title;
  final String category;
  final String imagePath;
  final String? garmentImagePath;
  final DateTime createdAt;

  SavedLook({
    required this.id,
    required this.title,
    required this.category,
    required this.imagePath,
    this.garmentImagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// What the UI listens to: who is logged in and where they are in onboarding.
class SessionState extends ChangeNotifier {
  SessionState(this._auth, this._store);

  final AuthService _auth;
  final SessionStore _store;

  bool isRestoring = true;
  bool isLoggedIn = false;
  bool hasCompletedOnboarding = false;
  UserProfile? currentUser;

  // Viewing preferences
  bool showCutoutMode = true;

  void toggleCutoutMode() {
    showCutoutMode = !showCutoutMode;
    notifyListeners();
  }

  List<GarmentItem> garments = [
    GarmentItem(
      id: 'g1',
      name: 'Structured Linen Blazer',
      imagePath: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=500&q=80',
      category: 'Outerwear',
      primaryColor: 'Beige',
      secondaryColor: 'Ivory',
      brand: 'Maison Vale',
      season: 'Spring / Fall',
      occasion: 'Smart Casual',
      tags: ['Tailored', 'Linen', 'Quiet Luxury'],
      isFavorite: true,
      source: 'digital_closet',
      wearCount: 5,
      lastWornAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    GarmentItem(
      id: 'g2',
      name: 'Fluid High-Waist Trouser',
      imagePath: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80',
      category: 'Bottoms',
      primaryColor: 'Espresso',
      secondaryColor: 'Black',
      brand: 'Forme Studio',
      season: 'All Season',
      occasion: 'Formal',
      tags: ['Draped', 'Minimalist', 'Wide-Leg'],
      isFavorite: true,
      source: 'digital_closet',
      wearCount: 8,
      lastWornAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GarmentItem(
      id: 'g3',
      name: 'Silk Button-Down Shirt',
      imagePath: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=500&q=80',
      category: 'Tops',
      primaryColor: 'White',
      secondaryColor: 'Cream',
      brand: 'Atelier Minimal',
      season: 'All Season',
      occasion: 'Work & Evening',
      tags: ['Silk', 'Classic', 'Elegance'],
      isFavorite: false,
      source: 'digital_closet',
      wearCount: 12,
      lastWornAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GarmentItem(
      id: 'g4',
      name: 'Sculpted Leather Loafers',
      imagePath: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=500&q=80',
      category: 'Shoes',
      primaryColor: 'Black',
      brand: 'L\'Artisan',
      season: 'Autumn / Winter',
      occasion: 'Casual & Formal',
      tags: ['Leather', 'Sculpted', 'Classic'],
      isFavorite: true,
      source: 'digital_closet',
      wearCount: 4,
      lastWornAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    GarmentItem(
      id: 'g5',
      name: 'Minimalist Shoulder Tote',
      imagePath: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=500&q=80',
      category: 'Bags',
      primaryColor: 'Brown',
      secondaryColor: 'Tan',
      brand: 'Céline sample',
      season: 'All Season',
      occasion: 'Everyday',
      tags: ['Structure', 'Leather', 'Essential'],
      isFavorite: false,
      source: 'digital_closet',
      wearCount: 15,
      lastWornAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GarmentItem(
      id: 'g6',
      name: 'Sculpted Gold Hoops',
      imagePath: 'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1630019852942-f89202989a59?auto=format&fit=crop&w=500&q=80',
      category: 'Accessories',
      primaryColor: 'Yellow',
      secondaryColor: 'Gold',
      brand: 'Forme Studio',
      season: 'All Season',
      occasion: 'Everyday & Special',
      tags: ['Jewelry', 'Gold', 'Statement'],
      isFavorite: true,
      source: 'digital_closet',
      wearCount: 0,
      lastWornAt: null,
    ),
    GarmentItem(
      id: 'g7',
      name: 'Pleated Slip Midi Dress',
      imagePath: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
      cutoutPath: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
      category: 'Dresses',
      primaryColor: 'Black',
      brand: 'Noir Atelier',
      season: 'Summer / Evening',
      occasion: 'Cocktail & Evening',
      tags: ['Silk', 'Fluid', 'Evening'],
      isFavorite: false,
      source: 'digital_closet',
      wearCount: 1,
      lastWornAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  List<PersonalCollection> personalCollections = [
    PersonalCollection(
      id: 'pc1',
      name: 'Black & Ivory',
      description: 'Timeless monochrome contrast for refined everyday styling',
      garmentIds: ['g2', 'g3', 'g4', 'g7'],
    ),
    PersonalCollection(
      id: 'pc2',
      name: 'Quiet Luxury',
      description: 'Relaxed tailoring, natural fabrics, and subdued tones',
      garmentIds: ['g1', 'g2', 'g3', 'g5'],
    ),
    PersonalCollection(
      id: 'pc3',
      name: 'Pieces I Want to Style',
      description: 'Statement pieces waiting for new garment combinations',
      garmentIds: ['g6', 'g7', 'g1'],
    ),
  ];

  List<SavedOutfit> savedOutfits = [
    SavedOutfit(
      id: 'so1',
      name: 'Atelier Afternoon Fit',
      occasion: 'Smart Casual',
      tags: ['Monochrome', 'Quiet Luxury'],
      positions: [
        CanvasPosition(garmentId: 'g1', dx: 0.3, dy: 0.3, scale: 1.0),
        CanvasPosition(garmentId: 'g2', dx: 0.7, dy: 0.6, scale: 0.95),
        CanvasPosition(garmentId: 'g5', dx: 0.2, dy: 0.7, scale: 0.8),
      ],
    ),
  ];

  void addGarment(GarmentItem item) {
    garments.insert(0, item);
    notifyListeners();
  }

  void updateGarment(GarmentItem updated) {
    final index = garments.indexWhere((g) => g.id == updated.id);
    if (index >= 0) {
      garments[index] = updated;
      notifyListeners();
    }
  }

  void deleteGarment(String id) {
    garments.removeWhere((g) => g.id == id);
    for (final col in personalCollections) {
      col.garmentIds.remove(id);
    }
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = garments.indexWhere((g) => g.id == id);
    if (index >= 0) {
      garments[index].isFavorite = !garments[index].isFavorite;
      notifyListeners();
    }
  }

  void addPersonalCollection(PersonalCollection collection) {
    personalCollections.insert(0, collection);
    notifyListeners();
  }

  void updatePersonalCollection(PersonalCollection collection) {
    final idx = personalCollections.indexWhere((c) => c.id == collection.id);
    if (idx >= 0) {
      personalCollections[idx] = collection;
      notifyListeners();
    }
  }

  void deletePersonalCollection(String id) {
    personalCollections.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void addGarmentToCollection(String collectionId, String garmentId) {
    final col = personalCollections.firstWhere((c) => c.id == collectionId, orElse: () => PersonalCollection(id: '', name: ''));
    if (col.id.isNotEmpty && !col.garmentIds.contains(garmentId)) {
      col.garmentIds.add(garmentId);
      notifyListeners();
    }
  }

  void removeGarmentFromCollection(String collectionId, String garmentId) {
    final col = personalCollections.firstWhere((c) => c.id == collectionId, orElse: () => PersonalCollection(id: '', name: ''));
    if (col.id.isNotEmpty) {
      col.garmentIds.remove(garmentId);
      notifyListeners();
    }
  }

  void saveOutfitComposition(SavedOutfit outfit) {
    final idx = savedOutfits.indexWhere((o) => o.id == outfit.id);
    if (idx >= 0) {
      savedOutfits[idx] = outfit;
    } else {
      savedOutfits.insert(0, outfit);
    }

    // Also push to savedLooks for seamless integration across app tabs
    final savedLook = SavedLook(
      id: outfit.id,
      title: outfit.name,
      category: 'Style Studio Outfit',
      imagePath: garments.firstWhere((g) => outfit.positions.any((p) => p.garmentId == g.id), orElse: () => garments.first).cutoutPath,
    );
    savedLooks.insert(0, savedLook);

    notifyListeners();
  }

  void deleteOutfit(String id) {
    savedOutfits.removeWhere((o) => o.id == id);
    savedLooks.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  LookbookModel currentDraft = LookbookModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: 'My Curated Lookbook',
    aestheticDescription: 'Quiet luxury meets modern romanticism',
    references: [
      LookbookReference(id: '1', imagePath: '', label: 'Color palette', category: 'General'),
      LookbookReference(id: '2', imagePath: '', label: 'Tones - warm, neutral...', category: 'General'),
    ],
    customCategories: [],
    createdAt: DateTime.now(),
  );

  List<LookbookModel> savedLookbooks = [];
  List<SavedLook> savedLooks = [];

  void saveLook(SavedLook look) {
    savedLooks.insert(0, look);
    notifyListeners();
  }

  void updateDraft(void Function(LookbookModel) update) {
    update(currentDraft);
    notifyListeners();
  }

  void saveCurrentDraft() {
    final existingIndex = savedLookbooks.indexWhere((l) => l.id == currentDraft.id);
    if (existingIndex >= 0) {
      savedLookbooks[existingIndex] = LookbookModel(
        id: currentDraft.id,
        title: currentDraft.title,
        aestheticDescription: currentDraft.aestheticDescription,
        references: currentDraft.references.map((r) => LookbookReference(id: r.id, imagePath: r.imagePath, label: r.label, category: r.category)).toList(),
        customCategories: List.from(currentDraft.customCategories),
        createdAt: currentDraft.createdAt,
      );
    } else {
      savedLookbooks.insert(
        0,
        LookbookModel(
          id: currentDraft.id,
          title: currentDraft.title,
          aestheticDescription: currentDraft.aestheticDescription,
          references: currentDraft.references.map((r) => LookbookReference(id: r.id, imagePath: r.imagePath, label: r.label, category: r.category)).toList(),
          customCategories: List.from(currentDraft.customCategories),
          createdAt: currentDraft.createdAt,
        ),
      );
    }
    notifyListeners();
  }

  void loadDraft(LookbookModel lookbook) {
    currentDraft = LookbookModel(
      id: lookbook.id,
      title: lookbook.title,
      aestheticDescription: lookbook.aestheticDescription,
      references: lookbook.references.map((r) => LookbookReference(id: r.id, imagePath: r.imagePath, label: r.label, category: r.category)).toList(),
      customCategories: List.from(lookbook.customCategories),
      createdAt: lookbook.createdAt,
    );
    notifyListeners();
  }

  void createNewDraft() {
    currentDraft = LookbookModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'My Curated Lookbook',
      aestheticDescription: '',
      references: [],
      customCategories: [],
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// True when the user can skip straight to the main app home screen.
  bool get shouldSkipToHome => isLoggedIn && hasCompletedOnboarding;

  /// Call once at startup, before runApp().
  Future<void> restore() async {
    final email = await _store.readEmail();
    if (email != null) {
      final result = await _auth.getSession(email);
      if (result != null && result.ok) {
        _apply(result);
      } else {
        await _store.clear(); // stale session (account was removed)
      }
    }
    isRestoring = false;
    notifyListeners();
  }

  Future<bool> accountExists(String email) => _auth.accountExists(email);

  /// Returns an error message, or null on success.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _finishAuth(_auth.signUp(name: name, email: email, password: password));

  Future<String?> logIn({
    required String email,
    required String password,
  }) =>
      _finishAuth(_auth.logIn(email: email, password: password));

  Future<String?> signInWithProvider({
    required SocialProvider provider,
    required String name,
    required String email,
  }) =>
      _finishAuth(_auth.signInWithProvider(
        provider: provider,
        name: name,
        email: email,
      ));

  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) =>
      _auth.resetPassword(email: email, newPassword: newPassword);

  /// State updates immediately; persistence follows, so callers may ignore
  /// the returned Future.
  Future<void> completeOnboarding() async {
    hasCompletedOnboarding = true;
    notifyListeners();
    final user = currentUser;
    if (user != null) await _auth.markOnboardingComplete(user.email);
  }

  Future<void> logOut() async {
    isLoggedIn = false;
    hasCompletedOnboarding = false;
    currentUser = null;
    notifyListeners();
    await _store.clear();
  }

  /// Runs [update] on the current profile, notifies, then saves it.
  Future<void> updateProfile(void Function(UserProfile) update) async {
    final user = currentUser;
    if (user == null) return;
    update(user);
    notifyListeners();
    await _auth.saveProfile(user);
  }

  Future<String?> _finishAuth(Future<AuthResult> pending) async {
    final result = await pending;
    if (!result.ok) return result.error;
    _apply(result);
    await _store.saveEmail(result.profile!.email);
    notifyListeners();
    return null;
  }

  void _apply(AuthResult result) {
    currentUser = result.profile;
    isLoggedIn = true;
    hasCompletedOnboarding = result.hasCompletedOnboarding;
  }
}
