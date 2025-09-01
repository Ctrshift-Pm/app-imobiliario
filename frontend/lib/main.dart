import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/broker_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tabs_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_property_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PropertyProvider>(
          create: (ctx) => PropertyProvider(null),
          update: (ctx, auth, _) => PropertyProvider(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BrokerProvider>(
          create: (ctx) => BrokerProvider(null),
          update: (ctx, auth, _) => BrokerProvider(auth.token),
        ),
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ConectImóvel',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF00a859),
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00a859),
                primary: const Color(0xFF00a859),
                secondary: const Color(0xFF008245),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00a859),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00a859), width: 2),
                ),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF00a859),
               colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00a859),
                brightness: Brightness.dark,
                primary: const Color(0xFF00a859),
                secondary: const Color(0xFF008245),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const OnboardingScreen(),
            routes: {
              WelcomeScreen.routeName: (ctx) => const WelcomeScreen(),
              LoginScreen.routeName: (ctx) => const LoginScreen(),
              RegisterScreen.routeName: (ctx) => const RegisterScreen(),
              TabsScreen.routeName: (ctx) => const TabsScreen(),
              PropertyDetailScreen.routeName: (ctx) => const PropertyDetailScreen(),
              ProfileScreen.routeName: (ctx) => const ProfileScreen(),
              SettingsScreen.routeName: (ctx) => const SettingsScreen(),
              AddPropertyScreen.routeName: (ctx) => const AddPropertyScreen(),
            },
          );
        },
      ),
    );
  }
}