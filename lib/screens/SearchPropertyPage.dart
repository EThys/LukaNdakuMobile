import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luka_ndaku/controllers/PropertyCtrl.dart';
import 'package:luka_ndaku/models/PropertyModel.dart';
import 'package:luka_ndaku/screens/DetailPropertyPage.dart';
import 'package:luka_ndaku/utils/Constantes.dart';
import 'package:luka_ndaku/utils/favorites_services.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tout';
  bool _isSearching = false;

  // Filtres
  String? _selectedCommune;
  String? _selectedType;
  String? _selectedTransaction;
  RangeValues _priceRange = RangeValues(0, 1000000);
  RangeValues _areaRange = RangeValues(0, 500);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      _performSearch();
    } else {
      setState(() {
        _isSearching = false;
      });
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    final propertyCtrl = Provider.of<PropertyController>(context, listen: false);
    await propertyCtrl.searchProperties(
      typeTransaction: _selectedTransaction,
      localisation: _selectedCommune,
    );
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _performSearch() async {
    final propertyCtrl = Provider.of<PropertyController>(context, listen: false);

    // Déterminez le type de propriété en fonction de la catégorie sélectionnée
    String? propertyType;
    if (_selectedCategory == 'Maisons') {
      propertyType = 'maison';
    } else if (_selectedCategory == 'Appartements') {
      propertyType = 'appartement';
    } else if (_selectedCategory == 'Terrain') {
      propertyType = 'terrain';
    } else if (_selectedCategory == 'Bureau') {
      propertyType = 'bureau';
    } else if (_selectedCategory == 'Villas') {
      propertyType = 'villa';
    }

    await propertyCtrl.searchProperties(
      typeTransaction: _selectedTransaction?.toLowerCase(),
      localisation: _selectedCommune,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showFilterSheet() {
    final List<String> allCommunes = [
      'Toutes les communes',
      'Bandalungwa',
      'Barumbu',
      'Bumbu',
      'Gombe',
      'Kalamu',
      'Kasa-Vubu',
      'Kimbanseke',
      'Kinshasa',
      'Kintambo',
      'Kisenso',
      'Lemba',
      'Limete',
      'Lingwala',
      'Makala',
      'Maluku',
      'Masina',
      'Matete',
      'Mont Ngafula',
      'Ndjili',
      'Ngaba',
      'Ngaliema',
      'Ngiri-Ngiri',
      'Nsele',
      'Selembao'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
                minHeight: 400, // Hauteur minimale pour les petits écrans
              ),
              margin: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle drag
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header élégant
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtrer les résultats',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 24),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),

                  // Contenu principal avec espace réservé pour les boutons
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 8,
                        bottom: 100, // Espace réservé pour les boutons
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Commune - Design moderne
                          _buildSectionHeader('Localisation'),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.grey.shade50,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCommune ?? 'Toutes les communes',
                                isExpanded: true,
                                icon: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.expand_more_rounded, color: Colors.grey.shade600),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                items: allCommunes.map((commune) {
                                  return DropdownMenuItem(
                                    value: commune,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Text(commune),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedCommune = value == 'Toutes les communes' ? null : value;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Section Type de transaction - Boutons élégants
                          _buildSectionHeader('Type de transaction'),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterChip(
                                  label: 'Location',
                                  selected: _selectedTransaction == 'Location',
                                  onTap: () {
                                    setModalState(() {
                                      _selectedTransaction =
                                      _selectedTransaction == 'Location' ? null : 'Location';
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterChip(
                                  label: 'Vente',
                                  selected: _selectedTransaction == 'Vente',
                                  onTap: () {
                                    setModalState(() {
                                      _selectedTransaction =
                                      _selectedTransaction == 'Vente' ? null : 'Vente';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Boutons en bas - Positionnement fixe et responsive
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCommune = null;
                                  _selectedTransaction = null;
                                  _priceRange = RangeValues(0, 1000000);
                                  _areaRange = RangeValues(0, 500);
                                });
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.grey.shade100,
                              ),
                              child: Text(
                                'Réinitialiser',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _refreshData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE53935),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Appliquer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFE53935).withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xFFE53935) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Color(0xFFE53935) : Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une propriété...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.filter_alt_outlined, color: Colors.grey[700]),
              onPressed: _showFilterSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Tout', 'Maisons', 'Appartements', 'Terrain', 'Bureau','Villas'];

    return Container(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = categories[index];
              });
              _refreshData();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCategory == categories[index]
                    ? Color(0xFFE53935).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedCategory == categories[index]
                      ? Color(0xFFE53935)
                      : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: _selectedCategory == categories[index]
                        ? Color(0xFFE53935)
                        : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

// Dans votre méthode _buildPropertyList ou équivalent:
//   Widget _buildPropertyList(List<PropertyModel> properties) {
//     final filteredProperties = _selectedCategory == 'Tout'
//         ? properties
//         : properties.where((property) {
//       switch (_selectedCategory) {
//         case 'Maisons':
//           return property.typeMaison?.toLowerCase() == 'maison';
//         case 'Appartements':
//           return property.typeMaison?.toLowerCase() == 'appartement';
//         case 'Terrain':
//           return property.typeMaison?.toLowerCase() == 'terrain';
//         case 'Commercial':
//           return property.typeMaison?.toLowerCase() == 'bureau' ||
//               property.typeMaison?.toLowerCase() == 'entrepôt';
//         default:
//           return true;
//       }
//     }).toList();
//
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: filteredProperties.length,
//       itemBuilder: (context, index) {
//         final property = filteredProperties[index];
//         return _ModernPropertyCard(property: property);
//       },
//     );
//   }

  Widget _buildLoadingIndicator() {
    return Center(
        child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
    ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Essayez de modifier vos critères de recherche ou élargissez vos filtres',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showFilterSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE53935),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Modifier les filtres',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList(List<PropertyModel> properties) {
    // Appliquer tous les filtres
    final filteredProperties = properties.where((property) {
      // Filtre par type de transaction
      final transactionMatch = _selectedTransaction == null ||
          property.typeTransaction?.toLowerCase() == _selectedTransaction?.toLowerCase();

      // Filtre par commune
      final communeMatch = _selectedCommune == null ||
          (property.localisation?.toLowerCase().contains(_selectedCommune!.toLowerCase()) ?? false);

      // Filtre par catégorie
      final categoryMatch = _selectedCategory == 'Tout' ||
          (_selectedCategory == 'Maisons' && property.typeMaison?.toLowerCase() == 'maison') ||
          (_selectedCategory == 'Appartements' && property.typeMaison?.toLowerCase() == 'appartement') ||
          (_selectedCategory == 'Terrain' && property.typeMaison?.toLowerCase() == 'terrain') ||
          (_selectedCategory == 'Villas' && property.typeMaison?.toLowerCase() == 'villa') ||
          (_selectedCategory == 'Bureau' &&
              (property.typeMaison?.toLowerCase() == 'bureau' ||
                  property.typeMaison?.toLowerCase() == 'entrepôt'));

      // Filtre par prix
      final price = property.typeTransaction == "location"
          ? double.tryParse(property.prixLocation ?? '0') ?? 0
          : double.tryParse(property.prixVente ?? '0') ?? 0;
      final priceMatch = price >= _priceRange.start && price <= _priceRange.end;

      // Filtre par superficie
      final area = double.tryParse(property.taille.toString()) ?? 0;
      final areaMatch = area >= _areaRange.start && area <= _areaRange.end;

      // Filtre par texte de recherche
      final searchText = _searchController.text.toLowerCase();
      final searchMatch = searchText.isEmpty ||
          (property.titre?.toLowerCase().contains(searchText) == true ||
              (property.localisation?.toLowerCase().contains(searchText) == true));

                  return transactionMatch &&
                  communeMatch &&
                  categoryMatch &&
                  priceMatch &&
                  areaMatch &&
                  searchMatch;
              }).toList();

    if (filteredProperties.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        final property = filteredProperties[index];
        return _ModernPropertyCard(property: property);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyCtrl = Provider.of<PropertyController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              floating: true,
              titleSpacing: 0,
              title: _buildSearchBar(),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60), // Augmentez la hauteur totale
                child: Padding(
                  padding: EdgeInsets.only(top: 10), // Espace de 10px en haut
                  child: _buildCategoryChips(),
                ),
              ),
            ),
          ];
        },
        body: propertyCtrl.loading || _isSearching
            ? _buildLoadingIndicator()
            : propertyCtrl.properties.isEmpty
            ? _buildEmptyState()
            : _buildPropertyList(propertyCtrl.properties),
      ),
    );
  }
}


class _ModernPropertyCard extends StatelessWidget {
  final PropertyModel property;

  const _ModernPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final FavoritesService favoritesService = FavoritesService();
    final imagePath = property.images.isNotEmpty ? property.images.first : '';
    final correctedPath = imagePath.replaceFirst(RegExp('^/'), '');
    final isFavorite = favoritesService.isFavorite(property.id ?? 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailPage(property: property),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Stack(
              children: [
                // Image avec Hero animation
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: property.images.isNotEmpty
                        ? Hero(
                      tag: 'property-image-${property.id}',
                      child: CachedNetworkImage(
                        imageUrl: '${Constantes.IMAGE_URL}$correctedPath',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
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

                // Bouton favori
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      try {
                        favoritesService.toggleFavorite(property.id ?? 0);
                        // Utilisez un Provider ou autre méthode pour déclencher un rebuild
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(favoritesService.isFavorite(property.id ?? 0)
                                  ? 'Ajouté aux favoris'
                                  : 'Retiré des favoris',

                              ),
                            ));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ),

                // Badge location/vente
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: property.typeTransaction == 'location'
                          ? Colors.red[600]
                          : Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.typeTransaction == 'location' ? 'À louer' : 'À vendre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
                            ? '${double.tryParse(property.prixLocation ?? '0')?.toInt()}\$/mois'
                            : '${double.tryParse(property.prixVente ?? '0')?.toInt()}\$',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    property.titre ?? "Pas de titre disponible",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Iconsax.location, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          property.localisation ?? 'Localisation non spécifiée',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if ((property.chambres ?? 0) > 0)
                        _ModernPropertyFeature(
                          icon: Icons.king_bed_rounded,
                          value: '${property.chambres} chambres',
                        ),
                      if ((property.sallesDeBain ?? 0) > 0)
                        _ModernPropertyFeature(
                          icon: Icons.bathtub_rounded,
                          value: '${property.sallesDeBain} sdb',
                        ),
                      _ModernPropertyFeature(
                        icon: Icons.aspect_ratio_rounded,
                        value: '${property.taille} m²',
                      ),
                    ],
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