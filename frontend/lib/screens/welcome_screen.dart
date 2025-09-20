import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'terms_screen.dart';
import 'tabs_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonsFadeAnimation;

  List<Particle> particles = [];
  final int _particleCount = 20;
  final Random _random = Random();
  bool _particlesInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Controlador para a animação de partículas (contínua)
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Controlador para a animação de entrada dos elementos (executa uma vez)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Define as animações faseadas
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.5)),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.3, 0.8)),
    );
    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeParticles();
        _fadeController.forward(); // Inicia a animação de entrada
      }
    });
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;
    setState(() {
      for (int i = 0; i < _particleCount; i++) {
        particles.add(Particle(
          offset: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          direction: _random.nextDouble() * 2 * pi,
          speed: 0.2 + _random.nextDouble() * 0.5,
          size: 1.0 + _random.nextDouble() * 2.0,
          color: Colors.white.withOpacity(0.4 + _random.nextDouble() * 0.3),
        ));
      }
      _particlesInitialized = true;
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.height < 700;

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (auth.isAuthenticated && mounted) {
            Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
          }
        });
        
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D5D50), // Verde escuro principal
                  Color(0xFF107564),
                ],
              ),
            ),
            child: Stack(
              children: [
                if (_particlesInitialized)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) => CustomPaint(
                          painter: ParticlePainter(particles, mediaQuery.size),
                        ),
                      ),
                    ),
                  ),
                
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        
                        FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Bem-vindo(a)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 28 : 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'A plataforma que liga você ao seu próximo imóvel.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: isSmallScreen ? 16 : 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),

                        FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pushNamed(LoginScreen.routeName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0D5D50),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Fazer login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).pushNamed('/register'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Registrar-se', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Classe de Partículas
class Particle {
  Offset offset;
  double direction;
  double speed;
  double size;
  Color color;

  Particle({
    required this.offset,
    required this.direction,
    required this.speed,
    required this.size,
    required this.color,
  });

  void update(Size size) {
    offset += Offset(cos(direction) * speed, sin(direction) * speed);
    if (offset.dx < 0) offset = Offset(size.width, offset.dy);
    if (offset.dx > size.width) offset = Offset(0, offset.dy);
    if (offset.dy < 0) offset = Offset(offset.dx, size.height);
    if (offset.dy > size.height) offset = Offset(offset.dx, 0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Size size;

  ParticlePainter(this.particles, this.size);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(this.size);
      final paint = Paint()..color = particle.color;
      canvas.drawCircle(particle.offset, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}