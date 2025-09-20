import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import '../widgets/logo_widget.dart';

enum AuthMode { login, register }
enum Role { client, broker }

class AuthLandingScreen extends StatefulWidget {
  static const routeName = '/auth-landing';
  const AuthLandingScreen({super.key});

  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen> {
  AuthMode _authMode = AuthMode.login;
  Role _role = Role.client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/splash1.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LogoWidget(height: 80),
                        const SizedBox(height: 16),
                        Text(
                          _authMode == AuthMode.login ? 'Bem-vindo de Volta!' : 'Crie a sua Conta',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        SegmentedButton<Role>(
                          segments: const [
                            ButtonSegment(value: Role.client, label: Text('Cliente'), icon: Icon(Icons.person_outline)),
                            ButtonSegment(value: Role.broker, label: Text('Corretor'), icon: Icon(Icons.badge_outlined)),
                          ],
                          selected: {_role},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _role = newSelection.first;
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            selectedForegroundColor: theme.primaryColor,
                            selectedBackgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            );
                          },
                          child: AuthForm(
                            key: ValueKey('${_authMode.name}-${_role.name}'),
                            authMode: _authMode,
                            role: _role,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
                            });
                          },
                          child: Text(
                            _authMode == AuthMode.login ? 'Não tem uma conta? Registar' : 'Já tem uma conta? Entrar',
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}