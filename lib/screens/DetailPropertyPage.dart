import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:luka_ndaku/utils/favorites_services.dart';

import '../models/PropertyModel.dart';
import '../utils/Constantes.dart';
import '../utils/Routes.dart';

class PropertyDetailPage extends StatefulWidget {
  final PropertyModel ? property;
  const PropertyDetailPage({Key? key, required this.property}) : super(key: key);

  @override
  _PropertyDetailPageState createState() => _PropertyDetailPageState();
}


class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final List<String> _propertyImages = [
    'assets/images/home1.jpg',
    'assets/images/home2.jpg',
    'assets/images/home3.jpg',
    'assets/images/home2.jpg',
  ];

  int _currentImageIndex = 0;
  bool _isFavorite = false;
  late FavoritesService _favoritesService;

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    if (widget.property?.id != null) {
      final isFav = _favoritesService.isFavorite(widget.property!.id!);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _toggleFavorite() async {
    if (widget.property?.id == null) return;

    try {
      _favoritesService.toggleFavorite(widget.property!.id!);
      final newStatus = !_isFavorite;

      setState(() {
        _isFavorite = newStatus;
      });

      _showFavoriteSnackbar(context, newStatus, widget.property?.titre ?? '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  _buildImageCarousel(),
                  // Positionnement du prix en overlay sur l'image
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${ widget.property?.typeTransaction == "location"
                            ? '${double.tryParse(widget.property?.prixLocation ?? '0')?.toInt()}\$/mois'
                            : '${double.tryParse(widget.property?.prixVente ?? '0')?.toInt()}\$'}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: _toggleFavorite, // Utilise la nouvelle méthode
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre seul maintenant que le prix est déplacé
                  Text(
                    "${widget.property?.titre}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Localisation
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Text(
                          "${widget.property?.localisation}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Caractéristiques avec prix mensuel pour location
                  _buildFeaturesRow(),
                  SizedBox(height: 24),

                  // Description
                  _buildDescriptionSection(),
                  SizedBox(height: 24),

                  // Equipements
                  _buildAmenitiesSection(),
                  SizedBox(height: 24),

                  // Contact
                  _buildContactCard(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.property?.images.length ?? 0,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            // Récupérer le chemin de l'image courante
            final imagePath = widget.property?.images[index] ?? '';
            // Supprimer le slash initial s'il existe
            final correctedPath = imagePath.replaceFirst(RegExp('^/'), '');
            // Construire l'URL complète
            final imageUrl = '${Constantes.IMAGE_URL}$correctedPath';

            print("URL de l'image $index: $imageUrl");

            return CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
          },
        ),

        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.property?.images.map((url) {
              int index = widget.property!.images.indexOf(url);
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }).toList() ?? [],
          ),
        ),
      ],
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

  Widget _buildFeaturesRow() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(Icons.king_bed,"${widget.property?.chambres}", "Chambres"),
            VerticalDivider(color: Colors.grey[300], thickness: 1),
            _buildFeatureItem(Icons.bathtub, "${widget.property?.sallesDeBain}", "Salles de bain"),
            VerticalDivider(color: Colors.grey[300], thickness: 1),
            _buildFeatureItem(Icons.square_foot, "${widget.property?.taille?.toInt()}", "m²"),
            VerticalDivider(color: Colors.grey[300], thickness: 1),
            _buildFeatureItem(Icons.calendar_today,
                "${ widget.property?.typeTransaction == "location"
                    ? '${double.tryParse(widget.property?.prixLocation ?? '0')?.toInt()}'
                    : '${double.tryParse(widget.property?.prixVente ?? '0')?.toInt()}\$'}","\$/mois"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.red[700]),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final imagePath = widget.property?.images.first;
    final correctedPath = imagePath?.replaceFirst('/', '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '${widget.property?.description}',
          style: TextStyle(
            height: 1.5,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = (widget.property?.equipements ?? [])
        .map((a) => a.toString().replaceAll(RegExp(r'\{nom:|\}|\"'), '').trim())
        .where((a) => a.isNotEmpty)
        .toList();

    if (amenities.isEmpty) return SizedBox();

    final amenityIcons = {
      'Parking': Icons.local_parking,
      'Climatisation': Icons.ac_unit,
      'Piscine': Icons.pool,
      'Cuisine équipée': Icons.kitchen,
      'Jardin': Icons.nature,
      'Terrasse': Icons.nature,
      'Chauffage': Icons.heat_pump,
      'Wifi': Icons.wifi,
      'Ascenseur': Icons.elevator,
      'Gardien': Icons.security,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            "Équipements",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final amenity = amenities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          amenityIcons[amenity] ?? Icons.help_outline_rounded,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            amenity,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/agent.jpg'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Josue Saidi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Agent immobilier - LOGER NGA",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.star, color: Colors.amber, size: 20),
                Text("4.9", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.message, color: Colors.red[700]),
                    label: Text("Message",style: TextStyle(color: Colors.black),),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                    onPressed: () {Navigator.pushNamed(context, Routes.chatPageRoute);},
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.call, color: Colors.white),
                    label: Text("Appeler",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton favori
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: _isFavorite ? Colors.red : Colors.grey[700],
                ),
                onPressed: _toggleFavorite, // Utilise la nouvelle méthode
              ),
            ),
            SizedBox(width: 12),
            // Bouton principal
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.email, color: Colors.white),
                label: Text(
                  "Contacter l'agence",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}