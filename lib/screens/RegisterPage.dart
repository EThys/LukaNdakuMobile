import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:luka_ndaku/controllers/AuthentificationCtrl.dart';
import 'package:luka_ndaku/utils/Routes.dart';
import 'package:luka_ndaku/utils/networkCheck.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4; // Changé de 5 à 4 car on supprime les centres d'intérêt
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isProcessing = false;

  // Form data
  final Map<String, dynamic> _formData = {
    'username': '',
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

  Future<void> _submitForm() async {
    // Empêcher les soumissions multiples
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Fermer le clavier
    FocusScope.of(context).unfocus();

    try {
      // 1. Validation des champs obligatoires
      if (_formData['username']?.isEmpty ?? true ||
          _formData['telephone']?.isEmpty ?? true ||
          _formData['password']?.isEmpty ?? true) {
        _showModernSnackBar(
          message: "Veuillez remplir tous les champs obligatoires",
          isError: true,
        );
        setState(() => _isProcessing = false);
        return;
      }

      // 2. Validation du mot de passe
      if (_formData['password']!.length < 8) {
        _showModernSnackBar(
          message: "Le mot de passe doit contenir au moins 8 caractères",
          isError: true,
        );
        setState(() => _isProcessing = false);
        return;
      }

      // 3. Vérification de la connexion internet
      final isConnected = await NetworkUtils.checkInternetConnectivity();
      if (!isConnected) {
        _showModernSnackBar(
          message: "Connexion internet requise",
          isError: true,
        );
        setState(() => _isProcessing = false);
        return;
      }

      setState(() {
        _isLoading = true;
        _isSubmitting = true; // Activer l'état de soumission
      });

      // 4. Préparation des données pour l'API
      final registrationData = {
        "username": _formData['username']!.trim(),
        "postnom": _formData['postnom']?.trim(),
        "genre": _formData['genre'],
        "date_naissance": _formData['date_naissance'] != null
            ? DateFormat('yyyy-MM-dd').format(_formData['date_naissance']!)
            : null,
        "telephone": _formData['telephone']!.trim(),
        "email": _formData['email']?.trim(),
        "pays": _formData['pays'],
        "ville": _formData['ville'],
        "profession": _formData['profession'],
        "password": _formData['password']!,
      };

      // 5. Appel à l'API d'inscription
      final ctrl = context.read<AuthentificationCtrl>();
      final res = await ctrl.register(registrationData);

      if (!mounted) return;

      // 6. Vérification de la réponse
      final isSuccess =
          (res.data?['message']?.toString().toLowerCase().contains('utilisateur') ?? false);

      if (isSuccess) {
        _showSuccessSnackBar("Inscription réussie!");
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginRoute,
                (route) => false,
          );
        }
      } else {
        // Gestion des erreurs améliorée
        String errorMessage = "Erreur lors de l'inscription";
        final responseData = res.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('email') &&
              responseData['email'].toString().contains("already exists")) {
            errorMessage = "Un compte existe déjà avec cet email";
          } else if (responseData.containsKey('telephone') &&
              responseData['telephone'].toString().contains("already exists")) {
            errorMessage = "Ce numéro de téléphone est déjà utilisé";
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
        }

        _showModernSnackBar(
          message: errorMessage,
          isError: true,
        );
      }
    } on TimeoutException catch (_) {
      _showModernSnackBar(
        message: "Temps écoulé, veuillez réessayer",
        isError: true,
      );
    } catch (e) {
      _showModernSnackBar(
        message: "Erreur technique lors de l'inscription",
        isError: true,
      );
      debugPrint("Registration error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false;
          _isSubmitting = false; // Désactiver l'état de soumission
        });
      }
    }
  }

  void _showModernSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }


  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Center(child: Text(message))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/success.json',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'Inscription réussie!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Votre compte a été créé avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to home page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Commencer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;
    const primaryColor = Color(0xFFE53935);
    const secondaryColor = Color(0xFFEF5350);

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFFCE4EC)],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Column(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _totalPages,
                          effect: ExpandingDotsEffect(
                            activeDotColor: primaryColor,
                            dotColor: Colors.grey[300]!,
                            dotHeight: 8,
                            dotWidth: 8,
                            expansionFactor: 3,
                            spacing: 6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Étape ${_currentPage + 1}/$_totalPages',
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form pages - Utilise Expanded avec un SingleChildScrollView
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80), // Espace pour les boutons
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _PersonalInfoStep(formData: _formData),
                          _ContactInfoStep(formData: _formData),
                          _ProfessionalInfoStep(formData: _formData),
                          _SecurityStep(formData: _formData),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Navigation buttons - Positionné en bas avec SafeArea
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFE53935)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Retour',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                              if (isLastPage) {
                                _submitForm();
                              } else {
                                _nextPage();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              isLastPage ? 'Terminer' : 'Continuer',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _PersonalInfoStep extends StatelessWidget {
  final Map<String, dynamic> formData;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _postnomController = TextEditingController();
  String? _selectedGenre;
  DateTime? _selectedDate;

  _PersonalInfoStep({required this.formData}) {
    _usernameController.text = formData['username'] ?? '';
    _postnomController.text = formData['postnom'] ?? '';
    _selectedGenre = formData['genre'];
    _selectedDate = formData['date_naissance'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Renseignez vos informations de base',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Nom
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Iconsax.user),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
              onChanged: (value) => formData['username'] = value,
            ),
            const SizedBox(height: 20),

            // Postnom
            TextFormField(
              controller: _postnomController,
              decoration: const InputDecoration(
                labelText: 'Postnom',
                prefixIcon: Icon(Iconsax.user),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre postnom';
                }
                return null;
              },
              onChanged: (value) => formData['postnom'] = value,
            ),
            const SizedBox(height: 20),

            // Genre
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: const InputDecoration(
                labelText: 'Genre',
                prefixIcon: Icon(Iconsax.profile_2user),
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
            const SizedBox(height: 20),

            // Date de naissance - Format français
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: Icon(Iconsax.calendar),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFFE53935), // Rouge
                          onPrimary: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935), // Rouge
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
              controller: TextEditingController(
                text: _selectedDate == null
                    ? null
                    : DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate!), // Format français
              ),
            ),
            const SizedBox(height: 20),
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
                labelText: 'Email',
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