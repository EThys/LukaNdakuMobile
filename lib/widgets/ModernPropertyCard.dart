import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luka_ndaku/screens/LoginPage.dart';
import 'package:luka_ndaku/utils/favorites_services.dart';

import '../models/PropertyModel.dart';
import '../screens/DetailPropertyPage.dart';
import '../utils/Constantes.dart';

class ModernPropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggled;

  const ModernPropertyCard({
    Key? key,
    required this.property,
    this.isFavorite = false,
    this.onFavoriteToggled,
  }) : super(key: key);

  @override
  _ModernPropertyCardState createState() => _ModernPropertyCardState();
}

class _ModernPropertyCardState extends State<ModernPropertyCard> {
  late bool _isFavorite;
  bool _isProcessingFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _initializeFavoriteStatus();
  }

  @override
  void didUpdateWidget(ModernPropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });
    }
  }

  Future<void> _initializeFavoriteStatus() async {
    try {
      if (widget.property.id == null) return;

      final isActuallyFavorite = _favoritesService.isFavorite(widget.property.id!);
      if (mounted && isActuallyFavorite != _isFavorite) {
        setState(() {
          _isFavorite = isActuallyFavorite;
        });
      }
    } catch (e) {
      debugPrint('Error initializing favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessingFavorite || widget.property.id == null) return;

    setState(() {
      _isProcessingFavorite = true;
    });

    try {
      // Vérifier la connexion utilisateur
      if (!_favoritesService.isUserLoggedIn()) {
        final shouldLogin = await _showLoginRequiredDialog();
        if (shouldLogin == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
        return;
      }

      // Sauvegarder l'ancien état pour rollback si besoin
      final oldFavoriteState = _isFavorite;

      // Mettre à jour l'UI immédiatement
      setState(() {
        _isFavorite = !_isFavorite;
      });

      // Feedback haptique
      HapticFeedback.lightImpact();

      // Mettre à jour dans le stockage
      _favoritesService.toggleFavorite(widget.property.id!);

      // Notifier le parent si nécessaire
      widget.onFavoriteToggled?.call();

      _showFavoriteSnackbar(_isFavorite);
    } catch (e) {
      // Revenir à l'ancien état en cas d'erreur
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
          } finally {
          if (mounted) {
          setState(() {
          _isProcessingFavorite = false;
          });
          }
          }
      }

  Future<bool?> _showLoginRequiredDialog() async {
    return await showDialog<bool>(
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
            child: Text(
              'Se connecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFavoriteSnackbar(bool isFavorite) {
    final message = isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris';
    final color = isFavorite ? Color(0xFFE53935) : Colors.grey[700];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
      ),
    );
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailPage(property: widget.property),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.property.images.isNotEmpty
        ? widget.property.images.first
        : '';
    final correctedPath = imagePath.replaceFirst(RegExp('^/'), '');

    return GestureDetector(
      onTap: _navigateToDetail,
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
              )
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
                  aspectRatio: 16/9,
                  child: widget.property.images.isNotEmpty
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
                right: 12,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
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
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _isFavorite ? Colors.red : Colors.grey[600],
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
                    color: widget.property.typeTransaction == "location"
                        ? Colors.red[600]
                        : Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.property.typeTransaction == "location"
                        ? 'À louer'
                        : 'À vendre',
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
                      widget.property.typeTransaction == "location"
                          ? '${double.tryParse(widget.property.prixLocation ?? '0')?.toInt()}\$/mois'
                          : '${double.tryParse(widget.property.prixVente ?? '0')?.toInt()}\$',
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
                          '4.5',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  widget.property.titre ?? 'Titre non disponible',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.property.localisation ?? "Localisation non précisée",
                        style: TextStyle(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.property.chambres != null && widget.property.chambres! > 0)
                      _buildFeature(
                        icon: Icons.king_bed_outlined,
                        value: '${widget.property.chambres} chambres',
                      ),
                    if (widget.property.sallesDeBain != null && widget.property.sallesDeBain! > 0)
                      _buildFeature(
                        icon: Icons.bathtub_outlined,
                        value: '${widget.property.sallesDeBain} sdb',
                      ),
                    if (widget.property.taille != null)
                      _buildFeature(
                        icon: Icons.square_foot,
                        value: '${widget.property.taille?.toInt()} m²',
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

  Widget _buildFeature({required IconData icon, required String value}) {
    return Tooltip(
      message: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}