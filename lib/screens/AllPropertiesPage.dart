import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:luka_ndaku/models/PropertyModel.dart';
import 'package:luka_ndaku/screens/DetailPropertyPage.dart';
import 'package:provider/provider.dart';

import '../controllers/PropertyCtrl.dart';
import '../utils/Constantes.dart';
import '../utils/favorites_services.dart';
import '../widgets/ModernPropertyCard.dart';

class AllPropertiesPage extends StatefulWidget {
  final String transactionType;

  const AllPropertiesPage({Key? key, required this.transactionType}) : super(key: key);

  @override
  _AllPropertiesPageState createState() => _AllPropertiesPageState();
}

class _AllPropertiesPageState extends State<AllPropertiesPage> {
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
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyCtrl = Provider.of<PropertyController>(context);
    final filteredProperties = propertyCtrl.properties
        .where((p) => p.typeTransaction == widget.transactionType)
        .where((p) => p.titre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? true)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.transactionType == "location"
              ? "Toutes les locations"
              : "Toutes les ventes",
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
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
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
                      setState(() {
                        _searchQuery = '';
                      });
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
                  ? Center(
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
              )
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

  Widget _buildFeatureInfo({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.red),
        SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}