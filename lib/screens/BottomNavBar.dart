import 'package:flutter/material.dart';
import 'package:luka_ndaku/screens/ChatPage.dart';
import 'package:luka_ndaku/screens/FavoritePage.dart';
import 'package:luka_ndaku/screens/HomePage.dart';
import 'package:luka_ndaku/screens/ProfilePage.dart';
import 'package:luka_ndaku/screens/SearchPropertyPage.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  bool _showBadge = true; // Pour gérer la notification non lue

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    FavoritesPage(),
    ChatPage(),
    ProfilePage(),
  ];

  // Liste des labels pour chaque icône
  final List<String> _labels = [
    'Accueil',
    'Recherche',
    'Favoris',
    'Chat',
    'Profil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          child: Container(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 0),
                _buildNavItem(Icons.search_rounded, 1),
                _buildFavoriteItem(2),
                _buildNavItem(Icons.chat_bubble_outline_rounded, 3),
                _buildNavItem(Icons.person_outlined, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Color(0xFFE53935) : Colors.grey[600],
          ),
          SizedBox(height: 4),
          Text(
            _labels[index],
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Color(0xFFE53935) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _showBadge = false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? Icons.favorite_rounded : Icons.favorite_outline,
                size: 26,
                color: isSelected ? Color(0xFFE53935) : Colors.grey[600],
              ),
              if (_showBadge)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            _labels[index],
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Color(0xFFE53935) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}