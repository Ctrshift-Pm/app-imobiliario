import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false); 
    Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
      bodyTextStyle: TextStyle(fontSize: 19.0, color: Colors.grey),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Encontre o Seu Lar",
          body: "Explore milhares de imóveis para venda ou aluguer. A sua próxima casa está à distância de um clique.",
          image: _buildImage('assets/images/splash1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Conecte-se com Corretores",
          body: "Fale diretamente com corretores profissionais para agendar visitas e tirar as suas dúvidas.",
          image: _buildImage('assets/images/splash2.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Gestão Simplificada",
          body: "É corretor? Anuncie os seus imóveis e gira as suas vendas de forma fácil e intuitiva.",
          image: _buildImage('assets/images/splash3.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Saltar', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Começar', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: const Color(0xFFBDBDBD),
        activeColor: const Color(0xFF00a859),
        activeSize: const Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Center(
      child: Image.asset(assetName, height: 350.0),
    );
  }
}