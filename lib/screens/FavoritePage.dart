import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luka_ndaku/screens/DetailPropertyPage.dart';
import 'package:provider/provider.dart';

import '../controllers/PropertyCtrl.dart';
import '../models/PropertyModel.dart';
import '../utils/Constantes.dart';
import '../utils/Routes.dart';
import '../utils/StockageKeys.dart';
import '../utils/favorites_services.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<PropertyModel> _favoriteProperties = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = _storage.read(StockageKeys.tokenKey);
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });

    if (_isLoggedIn) {
      await _loadFavorites();
    } else {
      setState(() => _isLoading = false);
    }

    if (mounted) {
      _fadeController.forward();
    }
  }

  Future<void> _loadFavorites() async {
    final propertyCtrl = Provider.of<PropertyController>(context, listen: false);
    await propertyCtrl.properties;

    final favoritesService = FavoritesService();
    final favoriteIds = favoritesService.getFavorites();

    setState(() {
      _favoriteProperties = propertyCtrl.properties
          .where((property) => favoriteIds.contains(property.id))
          .toList();
      _isLoading = false;
    });
  }

  void _removeFavorite(int propertyId) {
    final favoritesService = FavoritesService();
    favoritesService.toggleFavorite(propertyId);

    setState(() {
      _favoriteProperties.removeWhere((property) => property.id == propertyId);
    });

    final removedProperty = _favoriteProperties.firstWhere(
          (property) => property.id == propertyId,
      orElse: () => throw StateError('Property with id $propertyId not found in favorites'),
    );


    if (removedProperty.id != null) {
      final snackBar = SnackBar(
        content: Text('"${removedProperty.titre}" a été supprimé des favoris'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ANNULER',
          textColor: Colors.white,
          onPressed: () {
            favoritesService.toggleFavorite(propertyId);
            _loadFavorites();
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.red[800],
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.red[800],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Mes favoris',
          style: TextStyle(
            color: Colors.red[800],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.red[800]),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          );
        },
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.red))
            : !_isLoggedIn
            ? _buildLoginPrompt()
            : _favoriteProperties.isEmpty
            ? _buildEmptyFavorites()
            : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Connectez-vous pour voir vos favoris',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Vos biens favoris seront enregistrés\naprès connexion à votre compte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, Routes.loginRoute);
            },
            child: const Text(
              'Se connecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun favoris pour le moment',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ajoutez des biens à vos favoris en cliquant\nsur l\'icône cœur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, Routes.bottomRoute);
            },
            child: const Text(
              'Explorer les biens',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  '${_favoriteProperties.length} ',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _favoriteProperties.length > 1
                      ? 'biens en favoris'
                      : 'bien en favori',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.filter_list,
                  color: Colors.red[800],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtrer',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final property = _favoriteProperties[index];
              return Dismissible(
                key: Key(property.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red[800],
                  ),
                ),
                onDismissed: (direction) => _removeFavorite(property.id),
                child: _FavoriteCard(
                  property: property,
                  onRemove: () => _removeFavorite(property.id),
                ),
              );
            },
            childCount: _favoriteProperties.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.property,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = property.images.isNotEmpty ? property.images.first : '';
    final correctedPath = imagePath.replaceFirst(RegExp('^/'), '');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailPage(property: property),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: property.images.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: '${Constantes.IMAGE_URL}$correctedPath',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.home_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: property.typeTransaction == "location"
                          ? Colors.red[600]
                          : Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.typeTransaction == "location"
                          ? 'À louer'
                          : 'À vendre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: onRemove,
                    iconSize: 24,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.titre ?? 'Titre non disponible',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        property.localisation ?? "Localisation non précisée",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (property.taille != null)
                        _InfoChip(
                          icon: Icons.zoom_out_map,
                          text: '${property.taille?.toInt()} m²',
                          color: Colors.red[800]!,
                        ),
                      const SizedBox(width: 8),
                      if (property.chambres != null && property.chambres! > 0)
                        _InfoChip(
                          icon: Icons.door_front_door_outlined,
                          text: '${property.chambres} chambres',
                          color: Colors.red[800]!,
                        ),
                      const Spacer(),
                      Text(
                        property.typeTransaction == "location"
                            ? '${double.parse(property.prixLocation).toInt()}\$/mois'
                            : '${double.parse(property.prixVente).toInt()}\$',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajouté aujourd\'hui',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}