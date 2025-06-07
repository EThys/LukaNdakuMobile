import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luka_ndaku/screens/BottomNavBar.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _gradientAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Color> _gradientColors = [
    Color(0xFFE53935),
    Color(0xFF721927),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.9), weight: 50),
      ],
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.1),
      end: Offset(0.0, -0.1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => BottomNavBar(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Arrière-plan animé avec dégradé
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(_gradientColors[0], _gradientColors[1],
                          _controller.value * 0.5)!,
                      Color.lerp(_gradientColors[1], _gradientColors[0],
                          _controller.value * 0.5)!,
                    ],
                  ),
                ),
              ),

              // Effet de particules
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(
                    animation: _particleAnimation,
                    color1: Colors.white.withOpacity(0.1),
                    color2: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),

              // Effet de vague animé en bas
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: _WaveClipper(_controller.value),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo avec animation complexe
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cercle externe pulsé
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            // Cercle moyen avec effet de lumière
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.7, end: 0.9)
                                  .animate(_scaleAnimation),
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.4),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Logo principal
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 0.6)
                                  .animate(_scaleAnimation),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.bolt_rounded,
                                  size: 50,
                                  color: _gradientColors[1],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 40),

                        // Texte avec animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _textScaleAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Loger Nga',
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 15,
                                        color: Colors.black.withOpacity(0.3),
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Votre solution innovante',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 60),

                        // Indicateur de chargement personnalisé
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SizedBox(
                            width: 200,
                            child: Stack(
                              children: [
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      width: constraints.maxWidth *
                                          (_controller.value * 0.8 + 0.2),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  _WaveClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);

    var firstControlPoint = Offset(size.width * 0.25,
        size.height * (0.7 - 0.1 * math.sin(animationValue * 2 * math.pi)));
    var firstEndPoint = Offset(size.width * 0.5,
        size.height * (0.7 + 0.1 * math.cos(animationValue * 2 * math.pi)));

    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75,
        size.height * (0.7 + 0.15 * math.sin(animationValue * 2 * math.pi)));
    var secondEndPoint = Offset(size.width, size.height * 0.7);

    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy,
      secondEndPoint.dx, secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color1;
  final Color color2;

  _ParticlePainter({
    required this.animation,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // Seed pour la cohérence des particules

    // Particules de fond
    for (var i = 0; i < 50; i++) {
      final progress = (i / 50 + animation.value) % 1.0;
      final xPos = size.width * rng.nextDouble();
      final yPos = size.height * 0.2 + size.height * 0.6 * progress;
      final radius = 1.5 + 3 * rng.nextDouble();
      final opacity = 0.2 + 0.3 * rng.nextDouble();

      final paint = Paint()
        ..color = color1.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius * (0.8 + 0.4 * math.sin(animation.value * 2 * math.pi + i)),
        paint,
      );
    }

    // Particules plus visibles
    for (var i = 0; i < 20; i++) {
      final progress = (i / 20 + animation.value * 0.5) % 1.0;
      final xPos = size.width * rng.nextDouble();
      final yPos = size.height * 0.3 + size.height * 0.4 * progress;
      final radius = 2 + 4 * rng.nextDouble();

      final paint = Paint()
        ..color = color2.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius * (0.7 + 0.6 * math.sin(animation.value * 4 * math.pi + i * 0.5)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2;
  }
}