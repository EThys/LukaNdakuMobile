import 'package:get_storage/get_storage.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  static const String _tokenKey = 'TOKEN';
  final GetStorage _storage;

  FavoritesService() : _storage = GetStorage();

  // Méthode publique pour vérifier si l'utilisateur est connecté
  bool isUserLoggedIn() {
    return _isUserLoggedIn();
  }

  List<int> getFavorites() {
    if (!_isUserLoggedIn()) return [];
    try {
      final favorites = _storage.read(_favoritesKey);
      return favorites != null ? List<int>.from(favorites as List) : [];
    } catch (e) {
      print('Error reading favorites: $e');
      return [];
    }
  }

  void toggleFavorite(int propertyId) {
    if (!_isUserLoggedIn()) {
      throw Exception("L'utilisateur doit être connecté pour gérer les favoris");
    }

    try {
      final favorites = getFavorites();
      if (favorites.contains(propertyId)) {
        favorites.remove(propertyId);
      } else {
        favorites.add(propertyId);
      }
      _storage.write(_favoritesKey, favorites);
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception("Erreur lors de la mise à jour des favoris");
    }
  }

  bool isFavorite(int propertyId) {
    if (!_isUserLoggedIn()) return false;
    return getFavorites().contains(propertyId);
  }

  // Méthode privée pour vérifier la connexion
  bool _isUserLoggedIn() {
    try {
      final token = _storage.read(_tokenKey);
      return token != null && token is String && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Optionnel: Méthode pour écouter les changements d'état de connexion
  void listenToAuthChanges(Function(bool isLoggedIn) callback) {
    _storage.listenKey(_tokenKey, (value) {
      callback(value != null && value is String && value.isNotEmpty);
    });
  }
}