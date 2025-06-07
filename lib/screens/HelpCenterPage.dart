import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text('Centre d\'Aide',
            style: TextStyle(
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Color(0xFF4A5568)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            SizedBox(height: 28),
            _buildSearchSection(),
            SizedBox(height: 28),
            _buildPopularQuestions(),
            SizedBox(height: 28),
            _buildHelpCategories(),
            SizedBox(height: 20),
            _buildContactSection(),
            SizedBox(height: 10),
            _buildAppVersion(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, comment pouvons-nous vous aider?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
            height: 1.3,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Trouvez des réponses à vos questions ou contactez notre équipe de support',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF718096),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE2E8F0).withOpacity(0.8),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher des solutions...',
          hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
          prefixIcon: Icon(Icons.search_rounded,
            color: Color(0xFF718096),
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPopularQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions fréquemment posées',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 16),
        _buildQuestionTile(
          'Comment créer un compte?',
          'Suivez le processus d\'inscription avec votre email ou numéro de téléphone. La vérification se fait en 2 étapes simples.',
          Icons.account_circle_rounded,
          Color(0xFF4299E1),
        ),
        _buildQuestionTile(
          'Comment publier une annonce?',
          'Accédez à votre tableau de bord et cliquez sur "Créer une annonce". Remplissez les détails et publiez en quelques minutes.',
          Icons.add_home_work_rounded,
          Color(0xFF48BB78),
        ),
        _buildQuestionTile(
          'Comment contacter un propriétaire?',
          'Utilisez notre système de messagerie intégré. Les propriétaires reçoivent des notifications instantanées.',
          Icons.message_rounded,
          Color(0xFF9F7AEA),
        ),
      ],
    );
  }

  Widget _buildQuestionTile(String question, String answer, IconData icon, Color color) {
    return Builder(
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFEDF2F7),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(
                question,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                  fontSize: 15,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(72, 0, 16, 20),
                  child: Text(
                    answer,
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              tilePadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHelpCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parcourir par catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildCategoryCard(
              icon: FontAwesomeIcons.userAlt,
              title: 'Compte',
              subtitle: '5 articles',
              color: Color(0xFF4299E1),
            ),
            _buildCategoryCard(
              icon: FontAwesomeIcons.home,
              title: 'Annonces',
              subtitle: '12 articles',
              color: Color(0xFF48BB78),
            ),
            _buildCategoryCard(
              icon: FontAwesomeIcons.creditCard,
              title: 'Paiements',
              subtitle: '8 articles',
              color: Color(0xFFED8936),
            ),
            _buildCategoryCard(
              icon: FontAwesomeIcons.shieldAlt,
              title: 'Sécurité',
              subtitle: '6 articles',
              color: Color(0xFFF56565),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE2E8F0).withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Action when category is tapped
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Besoin d\'aide supplémentaire?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Notre équipe est disponible 24/7 pour répondre à vos questions',
          style: TextStyle(
            color: Color(0xFF718096),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 16),
        _buildContactOption(
          icon: Icons.email_rounded,
          title: 'Envoyer un email',
          subtitle: 'Réponse sous 24h',
          color: Color(0xFF4299E1),
        ),
        SizedBox(height: 12),
        _buildContactOption(
          icon: Icons.phone_rounded,
          title: 'Appeler le support',
          subtitle: 'Lun-Ven, 9h-17h',
          color: Color(0xFF48BB78),
        ),
        SizedBox(height: 12),
        _buildContactOption(
          icon: Icons.chat_bubble_rounded,
          title: 'Chat en direct',
          subtitle: 'Disponible maintenant',
          color: Color(0xFF9F7AEA),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE2E8F0).withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Action when contact option is tapped
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'Version 1.0.0 • © 2025 LogerNga',
        style: TextStyle(
          color: Color(0xFFA0AEC0),
          fontSize: 12,
        ),
      ),
    );
  }
}