import 'package:flutter/foundation.dart';

import '../data/local_db/session_store.dart';
import '../models/user_profile.dart';
import '../models/lookbook_model.dart';
import '../models/garment_item.dart';
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

  List<GarmentItem> garments = [
    GarmentItem(
      id: 'g1',
      name: 'Structured linen blazer',
      imagePath: '',
      cutoutPath: '',
      category: 'Outerwear',
      primaryColor: 'Beige',
      brand: 'Maison Vale',
      season: 'Spring / Fall',
      occasion: 'Smart Casual',
      isFavorite: true,
      source: 'digital_closet',
    ),
    GarmentItem(
      id: 'g2',
      name: 'High-waist tailored trousers',
      imagePath: '',
      cutoutPath: '',
      category: 'Bottoms',
      primaryColor: 'Espresso',
      brand: 'Forme Studio',
      season: 'All Season',
      occasion: 'Formal',
      isFavorite: false,
      source: 'digital_closet',
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
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = garments.indexWhere((g) => g.id == id);
    if (index >= 0) {
      garments[index].isFavorite = !garments[index].isFavorite;
      notifyListeners();
    }
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