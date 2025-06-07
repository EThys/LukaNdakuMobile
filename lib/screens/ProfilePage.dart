import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luka_ndaku/screens/BottomNavBar.dart';
import 'package:luka_ndaku/utils/AuthService.dart';
import 'package:luka_ndaku/utils/StockageKeys.dart';
import 'dart:io';

import '../utils/Routes.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetStorage storage = GetStorage();
  final Color primaryColor = Color(0xFFFA384F);
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF1E293B);
  final Color secondaryTextColor = Color(0xFF64748B);

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() async {
    final imagePath = storage.read('user_image_path');
    if (imagePath != null) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  bool get isLoggedIn {
    final token = storage.read(StockageKeys.tokenKey);
    return token != null && token.isNotEmpty;
  }

  String get safeUsername {
    return storage.read(StockageKeys.userKey)?['username']?.toString() ?? 'Invité';
  }

  String get safeEmail {
    return storage.read(StockageKeys.userKey)?['email']?.toString() ?? 'Non fourni';
  }

  String get safePhone {
    return storage.read(StockageKeys.userKey)?['telephone']?.toString() ?? 'Non fourni';
  }

  String get safeCity {
    return storage.read(StockageKeys.userKey)?['ville']?.toString() ?? 'Non fourni';
  }

  String get favoriteNumber {
    final token = storage.read(StockageKeys.tokenKey);
    final isLoggedIn = token != null && token is String && token.isNotEmpty;

    if (!isLoggedIn) {
      return '0';
    }
    final favorites = storage.read('favorites');

    switch (favorites) {
      case null:
        return '0';
      case String s when s.isEmpty:
        return '0';
      case String s:
        return '$s';
      case List l when l.isEmpty:
        return '0';
      case List l:
        return '${l.length}';
      default:
        return '0';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await storage.write('user_image_path', pickedFile.path);
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mon Profil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, Color(0xFF9E8BFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : Container(
                        color: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            safeUsername,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            safeEmail,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Nouveau', 'Statut', icon: Icons.person_pin_rounded),
                _buildStatItem(favoriteNumber, 'Favoris'),
                _buildStatItem('3', 'Messages', icon: Icons.message_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isLoggedIn) ...[
            _buildAuthItem(
              icon: Icons.login_rounded,
              title: 'Se connecter',
              onTap: _navigateToLogin,
              iconColor: Colors.red.shade700,
            ),
            Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
            _buildAuthItem(
              icon: Icons.person_add_rounded,
              title: 'Créer un compte',
              onTap: _navigateToSignup,
              iconColor: primaryColor,
            ),
          ],
          _buildAuthItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat',
              onTap: _navigateToChat,
              iconColor: Colors.red.shade700
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {IconData? icon}) {
    return Column(
      children: [
        icon != null
            ? Icon(icon, color: primaryColor, size: 24)
            : Text(
          value,
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileInfoItem(
            icon: Icons.person_outline_rounded,
            title: 'Nom complet',
            value: safeUsername,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
          _buildProfileInfoItem(
            icon: Icons.email_rounded,
            title: 'Email',
            value: safeEmail,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
          _buildProfileInfoItem(
            icon: Icons.phone_rounded,
            title: 'Téléphone',
            value: safePhone,
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
          _buildProfileInfoItem(
            icon: Icons.location_on_rounded,
            title: 'Ville',
            value: safeCity,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
        ],
      ),
    );
  }

  Widget _buildAuthItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }

  Widget _buildSecuritySection() {
    if (!isLoggedIn) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            onTap: () {},
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
          _buildActionItem(
            icon: Icons.lock_outline_rounded,
            title: 'Sécurité du compte',
            onTap: () {},
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
          _buildActionItem(
            icon: Icons.help_outline_rounded,
            title: 'Centre d\'aide',
            onTap: () { Navigator.pushNamed(context, Routes.HelpCenterPageRoute);},
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
          _buildActionItem(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
            onTap: _confirmLogout,
            iconColor: Colors.red.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 8),
          Text(
            'LogerNga v1.0.0',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '© 2025 LogerNga. Tous droits réservés',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, Routes.loginRoute);
  }

  void _navigateToChat() {
    Navigator.pushNamed(context, Routes.chatPageRoute);
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, Routes.registerRoute);
  }

  void _navigateToCreateProperty() {
    Navigator.pushNamed(context, Routes.createPropertyRoute);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 16),
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Voulez-vous vraiment vous déconnecter ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        try {
                          await AuthService.logout();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => BottomNavBar()),
                                (Route<dynamic> route) => false,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Déconnexion réussie'),
                              backgroundColor: Colors.green,
                            ),
                          );

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Échec de la déconnexion: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Déconnexion', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildProfileSection(),
              _buildAuthSection(),
              _buildActionSection(),
              _buildSecuritySection(),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }
}