import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Données du formulaire
  final Map<String, dynamic> _formData = {
    'nom': '',
    'postnom': '',
    'genre': null,
    'date_naissance': null,
    'telephone': '',
    'email': null,
    'pays': null,
    'ville': null,
    'profession': null,
    'password': '',

  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentPage--);
    }
  }

  void _submitForm() {


    print('Données du formulaire: $_formData');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Inscription réussie!'),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;
    const primaryColor = Color(0xFFE53935);

    return Theme(
      data: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(primary: primaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _totalPages,
                        effect: ExpandingDotsEffect(
                          activeDotColor: primaryColor,
                          dotColor: primaryColor.withOpacity(0.3),
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Étape ${_currentPage + 1}/$_totalPages',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages du formulaire
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _PersonalInfoStep(formData: _formData),
                      _ContactInfoStep(formData: _formData),
                      _ProfessionalInfoStep(formData: _formData),
                      _SecurityStep(formData: _formData),
                      _PreferencesStep(formData: _formData),
                    ],
                  ),
                ),

                // Boutons de navigation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFE53935)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Retour',
                              style: TextStyle(color: Color(0xFFE53935)),
                            ),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              _submitForm();
                            } else {
                              _nextPage();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? 'Terminer l\'inscription' : 'Continuer',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalInfoStep extends StatelessWidget {
  final Map<String, dynamic> formData;
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _postnomController = TextEditingController();
  String? _selectedGenre;
  DateTime? _selectedDate;

  _PersonalInfoStep({required this.formData}) {
    _nomController.text = formData['nom'] ?? '';
    _postnomController.text = formData['postnom'] ?? '';
    _selectedGenre = formData['genre'];
    _selectedDate = formData['date_naissance'];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Renseignez vos informations de base',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Nom
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Iconsax.user),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
              onChanged: (value) => formData['nom'] = value,
            ),
            const SizedBox(height: 16),

            // Postnom
            TextFormField(
              controller: _postnomController,
              decoration: InputDecoration(
                labelText: 'Postnom',
                prefixIcon: const Icon(Iconsax.user),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre postnom';
                }
                return null;
              },
              onChanged: (value) => formData['postnom'] = value,
            ),
            const SizedBox(height: 16),

            // Genre
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: InputDecoration(
                labelText: 'Genre',
                prefixIcon: const Icon(Iconsax.profile_2user),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                DropdownMenuItem(value: 'Femme', child: Text('Femme')),
              ],
              onChanged: (value) {
                _selectedGenre = value;
                formData['genre'] = value;
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner votre genre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date de naissance
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: const Icon(Iconsax.calendar),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                hintText: _selectedDate == null
                    ? 'Sélectionnez une date'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                filled: true,
                fillColor: Colors.white,
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
                  locale: const Locale('fr', 'FR'),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFFE53935),
                          onPrimary: Colors.white,
                          onSurface: Colors.grey[800]!,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  _selectedDate = date;
                  formData['date_naissance'] = date;
                  (context as Element).markNeedsBuild();
                }
              },
              validator: (value) {
                if (_selectedDate == null) {
                  return 'Veuillez sélectionner votre date de naissance';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoStep extends StatefulWidget {
  final Map<String, dynamic> formData;

  const _ContactInfoStep({required this.formData});

  @override
  State<_ContactInfoStep> createState() => _ContactInfoStepState();
}

class _ContactInfoStepState extends State<_ContactInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedPays;
  String? _selectedVille;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.formData['telephone'] ?? '';
    _emailController.text = widget.formData['email'] ?? '';
    _selectedPays = widget.formData['pays'];
    _selectedVille = widget.formData['ville'];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coordonnées',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comment pouvons-nous vous contacter ?',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Numéro de téléphone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixIcon: const Icon(Iconsax.call),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre numéro';
                }
                if (value.length < 8) {
                  return 'Numéro invalide';
                }
                return null;
              },
              onChanged: (value) => widget.formData['telephone'] = value,
            ),
            const SizedBox(height: 16),

            // Email (facultatif)
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email (facultatif)',
                prefixIcon: const Icon(Iconsax.sms),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => widget.formData['email'] = value.isEmpty ? null : value,
            ),
            const SizedBox(height: 16),

            // Pays
            DropdownButtonFormField<String>(
              value: _selectedPays,
              decoration: InputDecoration(
                labelText: 'Pays',
                prefixIcon: const Icon(Iconsax.global),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'RDC', child: Text('Congo Kinshasa')),
                DropdownMenuItem(value: 'France', child: Text('France')),
                DropdownMenuItem(value: 'Belgique', child: Text('Belgique')),
                DropdownMenuItem(value: 'Autre', child: Text('Autre')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPays = value;
                  _selectedVille = null;
                  widget.formData['pays'] = value;
                  widget.formData['ville'] = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner votre pays';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Ville
            DropdownButtonFormField<String>(
              value: _selectedVille,
              decoration: InputDecoration(
                labelText: 'Ville',
                prefixIcon: const Icon(Iconsax.building_3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _getVillesForPays(_selectedPays),
              onChanged: (value) {
                setState(() {
                  _selectedVille = value;
                  widget.formData['ville'] = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner votre ville';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getVillesForPays(String? pays) {
    if (pays == 'RDC') {
      return [
        const DropdownMenuItem(value: 'Kinshasa', child: Text('Kinshasa')),
        const DropdownMenuItem(value: 'Mbujimayi', child: Text('Mbujimayi')),
        const DropdownMenuItem(value: 'Lubumbashi', child: Text('Lubumbashi')),
        const DropdownMenuItem(value: 'Kananga', child: Text('Kananga')),
        const DropdownMenuItem(value: 'Kisangani', child: Text('Kisangani')),
        const DropdownMenuItem(value: 'Goma', child: Text('Goma')),
        const DropdownMenuItem(value: 'Bukavu', child: Text('Bukavu')),
        const DropdownMenuItem(value: 'Tshikapa', child: Text('Tshikapa')),
        const DropdownMenuItem(value: 'Kolwezi', child: Text('Kolwezi')),
        const DropdownMenuItem(value: 'Likasi', child: Text('Likasi')),
        const DropdownMenuItem(value: 'Kikwit', child: Text('Kikwit')),
        const DropdownMenuItem(value: 'Uvira', child: Text('Uvira')),
        const DropdownMenuItem(value: 'Bunia', child: Text('Bunia')),
        const DropdownMenuItem(value: 'Kalemie', child: Text('Kalemie')),
        const DropdownMenuItem(value: 'Mbandaka', child: Text('Mbandaka')),
        const DropdownMenuItem(value: 'Matadi', child: Text('Matadi')),
        const DropdownMenuItem(value: 'Kabinda', child: Text('Kabinda')),
        const DropdownMenuItem(value: 'Butembo', child: Text('Butembo')),
        const DropdownMenuItem(value: 'Baraka', child: Text('Baraka')),
        const DropdownMenuItem(value: 'Mwene-Ditu', child: Text('Mwene-Ditu')),
        const DropdownMenuItem(value: 'Isiro', child: Text('Isiro')),
        const DropdownMenuItem(value: 'Kindu', child: Text('Kindu')),
        const DropdownMenuItem(value: 'Boma', child: Text('Boma')),
        const DropdownMenuItem(value: 'Kamina', child: Text('Kamina')),
        const DropdownMenuItem(value: 'Gandajika', child: Text('Gandajika')),
        const DropdownMenuItem(value: 'Bandundu', child: Text('Bandundu')),
        const DropdownMenuItem(value: 'Gemena', child: Text('Gemena')),
        const DropdownMenuItem(value: 'Kipushi', child: Text('Kipushi')),
        const DropdownMenuItem(value: 'Bumba', child: Text('Bumba')),
        const DropdownMenuItem(value: 'Beni', child: Text('Beni')),
        const DropdownMenuItem(value: 'Lisala', child: Text('Lisala')),
        const DropdownMenuItem(value: 'Zongo', child: Text('Zongo')),
        const DropdownMenuItem(value: 'Kenge', child: Text('Kenge')),
        const DropdownMenuItem(value: 'Gbadolite', child: Text('Gbadolite')),
        const DropdownMenuItem(value: 'Inongo', child: Text('Inongo')),
        const DropdownMenuItem(value: 'Boende', child: Text('Boende')),
        const DropdownMenuItem(value: 'Buta', child: Text('Buta')),
        const DropdownMenuItem(value: 'Lusambo', child: Text('Lusambo')),

      ];
    } else if (pays == 'France') {
      return [
        const DropdownMenuItem(value: 'Paris', child: Text('Paris')),
        const DropdownMenuItem(value: 'Lyon', child: Text('Lyon')),
        const DropdownMenuItem(value: 'Marseille', child: Text('Marseille')),
        const DropdownMenuItem(value: 'Autre', child: Text('Autre')),
      ];
    } else if (pays == 'Belgique') {
      return [
        const DropdownMenuItem(value: 'Bruxelles', child: Text('Bruxelles')),
        const DropdownMenuItem(value: 'Anvers', child: Text('Anvers')),
        const DropdownMenuItem(value: 'Liège', child: Text('Liège')),
        const DropdownMenuItem(value: 'Autre', child: Text('Autre')),
      ];
    }
    return [
      const DropdownMenuItem(value: null, child: Text('Sélectionnez d\'abord un pays')),
    ];
  }
}

class _ProfessionalInfoStep extends StatefulWidget {
  final Map<String, dynamic> formData;

  const _ProfessionalInfoStep({required this.formData});

  @override
  State<_ProfessionalInfoStep> createState() => _ProfessionalInfoStepState();
}

class _ProfessionalInfoStepState extends State<_ProfessionalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProfession;
  final _autreProfessionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedProfession = widget.formData['profession'];
    if (_selectedProfession != null &&
        !['Proprietaire', 'Locataire', 'Commissionnaire'].contains(_selectedProfession)) {
      _autreProfessionController.text = widget.formData['profession'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profession',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Êtes-vous propriétaire, locataire ou commissionnaire ?',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Profession
            DropdownButtonFormField<String>(
              value: _selectedProfession,
              decoration: InputDecoration(
                labelText: 'Profession',
                prefixIcon: const Icon(Iconsax.briefcase),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'Proprietaire', child: Text('Propriétaire')),
                DropdownMenuItem(value: 'Locataire', child: Text('Locataire')),
                DropdownMenuItem(value: 'Commissionnaire', child: Text('Commissionnaire'))
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProfession = value;
                  widget.formData['profession'] = value == 'Autre'
                      ? _autreProfessionController.text
                      : value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner votre profession';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Si "Autres" est sélectionné
            if (_selectedProfession == 'Autre')
              TextFormField(
                controller: _autreProfessionController,
                decoration: InputDecoration(
                  labelText: 'Précisez votre profession',
                  prefixIcon: const Icon(Iconsax.edit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (_selectedProfession == 'Autre' && (value == null || value.isEmpty)) {
                    return 'Veuillez préciser votre profession';
                  }
                  return null;
                },
                onChanged: (value) => widget.formData['profession'] = value,
              ),
          ],
        ),
      ),
    );
  }
}

class _SecurityStep extends StatefulWidget {
  final Map<String, dynamic> formData;

  const _SecurityStep({required this.formData});

  @override
  State<_SecurityStep> createState() => _SecurityStepState();
}

class _SecurityStepState extends State<_SecurityStep> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = 'Faible';
  Color _strengthColor = Colors.red;
  double _strengthValue = 0.2;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    widget.formData['password'] = password;

    // Calcul de la force du mot de passe
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthValue = 0.0;
      });
      return;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;

    int strength = 0;
    if (hasMinLength) strength++;
    if (hasUppercase) strength++;
    if (hasDigits) strength++;
    if (hasLowercase) strength++;
    if (hasSpecialChars) strength++;

    setState(() {
      if (strength <= 2) {
        _passwordStrength = 'Faible';
        _strengthColor = Colors.red;
        _strengthValue = 0.3;
      } else if (strength == 3) {
        _passwordStrength = 'Moyen';
        _strengthColor = Colors.orange;
        _strengthValue = 0.6;
      } else {
        _passwordStrength = 'Fort';
        _strengthColor = Colors.green;
        _strengthValue = 1.0;
      }
    });
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text &&
          _passwordController.text.isNotEmpty;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    if (_passwordStrength == 'Faible') {
      return 'Le mot de passe est trop faible';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sécurité',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez un mot de passe sécurisé',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Conseils pour mot de passe fort
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pour un mot de passe fort:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Minimum 8 caractères\n• Au moins une majuscule\n• Au moins un chiffre\n• Au moins un caractère spécial',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Indicateur de force du mot de passe
            if (_passwordStrength.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Force du mot de passe: $_passwordStrength',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _strengthValue,
                    backgroundColor: Colors.grey[200],
                    color: _strengthColor,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _passwordStrength,
                    style: TextStyle(
                      color: _strengthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Mot de passe
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Iconsax.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: _validatePassword,
              onChanged: (value) {
                _checkPasswordStrength();
                _checkPasswordMatch();
              },
            ),
            const SizedBox(height: 16),

            // Confirmation mot de passe
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmez le mot de passe',
                prefixIcon: const Icon(Iconsax.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _passwordsMatch ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _passwordsMatch ? Colors.green : const Color(0xFFE53935),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                suffix: _passwordsMatch
                    ? const Icon(Icons.check, color: Colors.green, size: 20)
                    : null,
              ),
              validator: _validateConfirmPassword,
              onChanged: (value) => _checkPasswordMatch(),
            ),
          ],
        ),
      ),
    );
  }
}


class _PreferencesStep extends StatefulWidget {
  final Map<String, dynamic> formData;

  const _PreferencesStep({required this.formData});

  @override
  State<_PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<_PreferencesStep> {
  final List<String> _selectedInterests = [];
  bool _minInterestsSelected = false;

  final List<Map<String, dynamic>> _interests = [
    {'id': 'sport', 'label': 'Sports', 'icon': Iconsax.danger},
    {'id': 'music', 'label': 'Musique', 'icon': Iconsax.music},
    {'id': 'tech', 'label': 'Technologie', 'icon': Iconsax.cpu},
    {'id': 'art', 'label': 'Art', 'icon': Iconsax.brush_2},
    {'id': 'travel', 'label': 'Voyage', 'icon': Iconsax.airplane},
    {'id': 'food', 'label': 'Cuisine', 'icon': Iconsax.cake},
    {'id': 'reading', 'label': 'Lecture', 'icon': Iconsax.book},
    {'id': 'games', 'label': 'Jeux', 'icon': Iconsax.game},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.formData['interests'] != null) {
      _selectedInterests.addAll(List<String>.from(widget.formData['interests']));
    }
    _updateMinInterestsStatus();
  }

  void _updateMinInterestsStatus() {
    setState(() {
      _minInterestsSelected = _selectedInterests.length >= 3;
    });
    widget.formData['interests'] = _selectedInterests;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Centres d\'intérêt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez au moins 3 centres d\'intérêt pour personnaliser votre expérience',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedInterests.length}/8 sélectionnés',
            style: TextStyle(
              color: _minInterestsSelected ? const Color(0xFFE53935) : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Grille d'intérêts
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _interests.length,
            itemBuilder: (context, index) {
              final interest = _interests[index];
              final isSelected = _selectedInterests.contains(interest['id']);

              return FilterChip(
                label: Text(
                  interest['label'],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE53935) : Colors.grey[700],
                  ),
                ),
                avatar: Icon(
                  interest['icon'],
                  size: 18,
                  color: isSelected ? const Color(0xFFE53935) : Colors.grey[600],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest['id']);
                    } else {
                      _selectedInterests.remove(interest['id']);
                    }
                    _updateMinInterestsStatus();
                  });
                },
                selectedColor: const Color(0xFFE53935).withOpacity(0.1),
                checkmarkColor: Color(0xFFE53935),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? const Color(0xFFE53935) : Colors.grey.shade300,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                showCheckmark: false,
              );
            },
          ),
          const SizedBox(height: 16),
          if (!_minInterestsSelected)
            Text(
              'Veuillez sélectionner au moins 3 centres d\'intérêt',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}