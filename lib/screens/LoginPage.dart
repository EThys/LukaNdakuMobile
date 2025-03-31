import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luka_ndaku/screens/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fakeLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      // Navigate to home after login
    }
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(left: 24,right: 24,bottom: 35,top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réinitialiser le mot de passe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Entrez votre email pour recevoir un lien de réinitialisation',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.sms),
                labelText: 'Votre email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lien de réinitialisation envoyé !'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Envoyer le lien',
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    const primaryColor = Color(0xFFE53935); // Vibrant orange
    const secondaryColor = Color(0xFFC62828); // Light orange
    const backgroundColor = Colors.white;
    const textColor = Colors.black87;
    const subtleTextColor = Color(0xFF616161);
    // const Color primaryRed = Color(0xFFE53935); // Rouge vifconst Color secondaryRed = Color(0xFFEF5350); // Rouge clair
    // static const Color darkRed = Color(0xFFC62828); // Rouge foncé
    // static const Color bgColor = Colors.white; // Fond blanc pour contraste

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and welcome
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.security_safe,
                            size: 32,
                            color: Colors.white,
                          ),
                        ).animate().scale(duration: 500.ms),
                        const SizedBox(height: 24),
                        Text(
                          'Bienvenue',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connectez-vous à votre compte',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtleTextColor,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 30),

                    Material(
                      elevation: 7,
                      borderRadius: BorderRadius.circular(16),
                      color: backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                validator: (value) => value!.isEmpty
                                    ? 'Veuillez entrer votre email'
                                    : !value.contains('@')
                                    ? 'Email invalide'
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Iconsax.sms, color: subtleTextColor),
                                  labelText: 'Adresse email',
                                  labelStyle: const TextStyle(color: subtleTextColor),
                                  floatingLabelStyle: const TextStyle(color: primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: primaryColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: textColor),
                              ).animate().fadeIn(delay: 200.ms),

                              const SizedBox(height: 20),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) => value!.isEmpty
                                    ? 'Veuillez entrer votre mot de passe'
                                    : value.length < 6
                                    ? 'Minimum 6 caractères'
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Iconsax.lock_1, color: subtleTextColor),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Iconsax.eye_slash
                                          : Iconsax.eye,
                                      color: subtleTextColor,
                                    ),
                                    onPressed: () => setState(
                                            () => _obscurePassword = !_obscurePassword),
                                  ),
                                  labelText: 'Mot de passe',
                                  labelStyle: const TextStyle(color: subtleTextColor),
                                  floatingLabelStyle: const TextStyle(color: primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: primaryColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: textColor),
                              ).animate().fadeIn(delay: 300.ms),

                              const SizedBox(height: 12),


                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) => setState(() => _rememberMe = value!),
                                          activeColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        Text(
                                          'Se souvenir',
                                          style: TextStyle(
                                            color: subtleTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showForgotPasswordSheet,
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 400.ms),

                              const SizedBox(height: 24),


                              ElevatedButton(
                                onPressed: _isLoading ? null : _fakeLogin,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 500.ms),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(
                            color: subtleTextColor,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrationPage()),
                            );
                          },
                          child: Text(
                            'S\'inscrire',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}