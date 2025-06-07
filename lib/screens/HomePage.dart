import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luka_ndaku/models/PropertyModel.dart';
import 'package:luka_ndaku/screens/AllPropertiesPage.dart';
import 'package:luka_ndaku/screens/DetailPropertyPage.dart';
import 'package:luka_ndaku/screens/LoginPage.dart';
import 'package:luka_ndaku/screens/PropertiesByType.dart';
import 'package:luka_ndaku/utils/Constantes.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/PropertyCtrl.dart';
import '../utils/favorites_services.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  Future<void> _refreshData() async {
    final propertyCtrl = Provider.of<PropertyController>(context, listen: false);
    await propertyCtrl.getAllProperty();
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Chargement initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyCtrl = Provider.of<PropertyController>(context, listen: false);
      propertyCtrl.getAllProperty().then((_) {
        print("Données chargées: ${propertyCtrl.properties.length} propriétés");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyCtrl = Provider.of<PropertyController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'LOGER ',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            children: [
              TextSpan(
                text: 'NGA',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Color(0xFFE53935), // Couleur du refresh indicator
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // Important pour le refresh
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPromoSection(context),
              _buildCategorySection(),

              // Section Locations avec Shimmer
              _buildSectionHeader(
                context,
                title: "Biens en Location",
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllPropertiesPage(transactionType: "location"),
                    ),
                  );
                },
              ),

              propertyCtrl.loading
                  ? _buildPropertyCarouselShimmer()
                  : _buildPropertyCarousel(
                context,
                properties: propertyCtrl.properties
                    .where((p) => p.typeTransaction == "location")
                    .toList(),
              ),

              _buildPromoCarousel(),

              // Section Ventes avec Shimmer
              _buildSectionHeader(
                context,
                title: "Biens en Vente",
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllPropertiesPage(transactionType: "vente"),
                    ),
                  );
                },
              ),
              propertyCtrl.loading
                  ? _buildPropertyCarouselShimmer()
                  : _buildPropertyCarousel(
                context,
                properties: propertyCtrl.properties
                    .where((p) => p.typeTransaction == "vente")
                    .toList(),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCarouselShimmer() {
    return Container(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 260,
              margin: EdgeInsets.only(right: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 20,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 16,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 40, height: 16, color: Colors.white),
                              Container(width: 40, height: 16, color: Colors.white),
                              Container(width: 40, height: 16, color: Colors.white),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: 80,
                            height: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.home_work_outlined,
                size: 180,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Trouvez votre maison de rêve',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Des milliers de propriétés exclusives à découvrir',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 2,
                  ),
                  child: Text(
                    'Explorer maintenant',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCarousel() {
    final promotions = [
      {
        'image': 'https://source.unsplash.com/random/800x600/?modern,house',
        'title': 'Offre Spéciale Été',
        'subtitle': 'Réduction de 15% sur les frais d\'agence',
      },
      {
        'image': 'https://source.unsplash.com/random/800x600/?luxury,apartment',
        'title': 'Nouveaux Projets',
        'subtitle': 'Découvrez nos dernières acquisitions',
      },
      {
        'image': 'https://source.unsplash.com/random/800x600/?city,view',
        'title': 'Investissement Locatif',
        'subtitle': 'Rendement garanti jusqu\'à 7%',
      },
    ];

    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(promotions[index]['image'] as String),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotions[index]['title'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    promotions[index]['subtitle'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text('En savoir plus'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'icon': Icons.apartment, 'label': 'Appartements', 'type': 'appartement'},
      {'icon': Icons.house, 'label': 'Maisons', 'type': 'maison'},
      {'icon': Icons.villa, 'label': 'Villas', 'type': 'villa'},
      {'icon': Icons.business, 'label': 'Bureaux', 'type': 'bureau'},
    ];

    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertiesByTypePage(
                    propertyType: categories[index]['type'] as String,
                  ),
                ),
              );
            },
            child: Container(
              width: 90,
              margin: EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      categories[index]['icon'] as IconData,
                      size: 28,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    categories[index]['label'] as String,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, {
        required String title,
        required VoidCallback onSeeAll,
      }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Voir tout',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFFE53935),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCarousel(BuildContext context, {required List<PropertyModel> properties}) {
    if (properties.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'Aucune propriété disponible',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return _buildPropertyCard(context, property: property);
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, {required PropertyModel property}) {
    final favoritesService = FavoritesService();
    bool isFavorite = favoritesService.isFavorite(property.id);
    final imagePath = property.images.isNotEmpty ? property.images.first : '';
    final correctedPath = imagePath.replaceFirst(RegExp(r'^/'), '');

    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    PropertyDetailPage(property: property),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      child: property.images.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: '${Constantes.IMAGE_URL}$correctedPath',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) => _buildImagePlaceholder(),
                      )
                          : _buildImagePlaceholder(),
                    ),
                  ),

                  // Overlay Gradient at Bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () async {
                        final favoritesService = FavoritesService();

                        if (!favoritesService.isUserLoggedIn()) {
                          final shouldLogin = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                'Connexion requise',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text('Connectez-vous pour gérer vos favoris'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Plus tard'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE53935),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Se connecter', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogin == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          }
                          return;
                        }

                        setState(() {
                          final wasFavorite = favoritesService.isFavorite(property.id);
                          favoritesService.toggleFavorite(property.id);
                          HapticFeedback.lightImpact();
                          _showFavoriteSnackbar(context, !wasFavorite, property.titre ?? '');
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            favoritesService.isFavorite(property.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey<bool>(favoritesService.isFavorite(property.id)),
                            color: favoritesService.isFavorite(property.id)
                                ? Color(0xFFE53935)
                                : Colors.grey[700],
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Transaction Type Badge (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFE53935),
                            Color(0xFFFF6D00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property.typeTransaction == "location" ? 'À LOUER' : 'À VENDRE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Location (Bottom Left)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          property.localisation ?? "Localisation non précisée",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 40, // Largeur du soulignement
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFE53935), // Rouge
                                Color(0xFFFF6D00), // Orange
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Details Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 16,bottom: 16,right: 16,top: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (property.titre ?? 'Titre non disponible').length > 17
                                  ? '${(property.titre ?? 'Titre non disponible').substring(0, 17)}...'
                                  : property.titre ?? 'Titre non disponible',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            property.typeTransaction == "location"
                                ? '${property.prixLocation?.split('.')[0]}\$/mois'
                                : '${property.prixVente?.split('.')[0]}\$',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // Features
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildModernFeatureInfo(
                            icon: Icons.king_bed_rounded,
                            value: '${property.chambres}',
                            label: 'Chambres',
                          ),
                          _buildModernFeatureInfo(
                            icon: Icons.bathtub_rounded,
                            value: '${property.sallesDeBain}',
                            label: 'SDB',
                          ),
                          _buildModernFeatureInfo(
                            icon: Icons.aspect_ratio_rounded,
                            value: '${property.taille?.toInt()}',
                            label: 'm²',
                          ),
                          _buildModernFeatureInfo(
                            icon: Icons.home_work_rounded,
                            value: property.typeMaison ?? '-',
                            label: 'Type',
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
      ),
    );
  }

  void _showFavoriteSnackbar(BuildContext context, bool isAdding, String propertyTitle) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(20, 0, 40, 30),
        duration: Duration(seconds: 2),
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isAdding ? Color(0xFFE53935).withOpacity(0.95) : Colors.grey[800]!.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isAdding ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAdding ? 'Ajouté aux favoris' : 'Retiré des favoris',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (propertyTitle.isNotEmpty)
                      Text(
                        propertyTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.white.withOpacity(0.8)),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFavoriteAddedAnimation(BuildContext context) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: MediaQuery.of(context).size.width / 2 - 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: Colors.white),
                SizedBox(width: 8),
                Text('Ajouté aux favoris', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 2), () => overlayEntry?.remove());
  }

  Widget _buildModernFeatureInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: Color(0xFFE53935),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      height: 180,
      width: double.infinity,
      child: Center(
        child: Icon(
          Icons.home_rounded,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}