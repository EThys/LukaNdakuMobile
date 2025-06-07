import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/PropertyCtrl.dart';
import '../models/PropertyModel.dart';
import '../utils/Constantes.dart';
import '../utils/favorites_services.dart';
import '../widgets/ModernPropertyCard.dart';
import 'DetailPropertyPage.dart';

class PropertiesByTypePage extends StatefulWidget {
  final String propertyType;

  const PropertiesByTypePage({Key? key, required this.propertyType}) : super(key: key);

  @override
  _PropertiesByTypePageState createState() => _PropertiesByTypePageState();
}

class _PropertiesByTypePageState extends State<PropertiesByTypePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  Future<void> _refreshProperties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final propertyCtrl = Provider.of<PropertyController>(context, listen: false);
      await propertyCtrl.properties;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshProperties();
  }

  @override
  Widget build(BuildContext context) {
    final propertyCtrl = Provider.of<PropertyController>(context);
    final filteredProperties = propertyCtrl.properties
        .where((p) => p.typeMaison?.toLowerCase() == widget.propertyType.toLowerCase())
        .where((p) => p.titre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? true)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.propertyType[0].toUpperCase()}${widget.propertyType.substring(1)}s',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[800]!, Colors.red[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Rechercher une propriété...',
                  prefixIcon: Icon(Icons.search, color: Colors.red),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProperties,
              color: Colors.red,
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
              child: _isLoading && filteredProperties.isEmpty
                  ? Center(child: CircularProgressIndicator(color: Colors.red))
                  : filteredProperties.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  return _buildPropertyCard(
                    context,
                    property: filteredProperties[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, {required PropertyModel property}) {
    final favoritesService = FavoritesService();
    bool isFavorite = favoritesService.isFavorite(property.id);

    return ModernPropertyCard(
      property: property,
      isFavorite: favoritesService.isFavorite(property.id),
      onFavoriteToggled: () {
        favoritesService.toggleFavorite(property.id);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 70, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'Aucune propriété trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Tirez vers le bas pour rafraîchir'
                : 'Aucun résultat pour "${_searchQuery}"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrer par', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Toutes les propriétés'),
                onTap: () {
                  // Implémentez la logique de filtre
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ListTile(
                title: Text('À louer'),
                onTap: () {
                  // Implémentez la logique de filtre
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ListTile(
                title: Text('À vendre'),
                onTap: () {
                  // Implémentez la logique de filtre
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModernPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final FavoritesService _favoritesService = FavoritesService();

  _ModernPropertyCard({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isFavorite = _favoritesService.isFavorite(property.id);
    final imagePath = property.images.isNotEmpty ? property.images.first : '';
    final correctedPath = imagePath.replaceFirst(RegExp('^/'), '');

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: InkWell(
                    onTap: onTap,
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
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    _favoritesService.toggleFavorite(property.id);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? Color(0xFFE53935) : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: property.typeTransaction == 'location'
                        ? Colors.red[600]
                        : Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    property.typeTransaction == 'location' ? 'À louer' : 'À vendre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Détails
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                    property.typeTransaction == "location"
                    ? '${double.parse(property.prixLocation).toInt()}\$/mois'
                    : '${double.parse(property.prixVente).toInt()}\$',

    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '4.8', // Vous pouvez ajouter un champ rating dans votre modèle
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  property.titre ?? 'Sans titre',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      property.localisation ?? 'Localisation inconnue',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (property.chambres != null && property.chambres! > 0)
                      _ModernPropertyFeature(
                        icon: Icons.king_bed,
                        value: '${property.chambres} chambres',
                      ),
                    if (property.sallesDeBain != null && property.sallesDeBain! > 0)
                      _ModernPropertyFeature(
                        icon: Icons.bathtub_outlined,
                        value: '${property.sallesDeBain} sdb',
                      ),
                    if (property.taille != null)
                      _ModernPropertyFeature(
                        icon: Icons.straighten,
                        value: '${property.taille?.toStringAsFixed(0)} m²',
                      ),
                    _ModernPropertyFeature(
                      icon: Icons.home_work_outlined,
                      value: property.typeMaison ?? '?',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPropertyFeature extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ModernPropertyFeature({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}