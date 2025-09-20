// terms_screen.dart
import 'package:flutter/material.dart';
import 'verification_screen.dart'; // Você precisará criar esta tela

class TermsScreen extends StatefulWidget {
  static const routeName = '/terms';
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _termsAccepted = false;
  Map<String, dynamic>? _registerData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtém os dados de registro passados como argumentos
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _registerData = args;
    }
  }

  void _continueToVerification() {
    if (_registerData != null) {
      // Navega para a tela de verificação (captura de fotos do CRECI)
      Navigator.of(context).pushReplacementNamed(
        VerificationScreen.routeName,
        arguments: _registerData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Condições'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Termos de Uso para Corretores',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTermSection(
                    '1. Aceitação dos Termos',
                    'Ao se registar como corretor na nossa plataforma, você concorda em cumprir integralmente com os presentes Termos e Condições, que regem o uso dos nossos serviços. A violação de qualquer termo pode resultar na suspensão ou encerramento da sua conta.',
                  ),
                  _buildTermSection(
                    '2. Qualidade dos Anúncios',
                    'O corretor compromete-se a fornecer informações verídicas, completas e atualizadas sobre os imóveis anunciados. É obrigatório o envio de um mínimo de 2 (duas) e um máximo de 25 (vinte e cinco) fotografias de alta qualidade por anúncio. Anúncios com informações falsas ou enganosas serão removidos.',
                  ),
                  _buildTermSection(
                    '3. Verificação de Identidade (CRECI)',
                    'Para garantir a segurança da plataforma, será solicitado o envio de documentos para verificação da sua identidade e do seu registo no Conselho Regional de Corretores de Imóveis (CRECI).',
                  ),
                  _buildTermSection(
                    '4. Período de Verificação',
                    'Após o envio dos documentos, sua conta ficará com status "em verificação" até que a equipe administrativa analise e aprove sua documentação. Durante este período, você poderá visualizar imóveis mas não poderá criar novos anúncios.',
                  ),
                  _buildTermSection(
                    '5. Responsabilidades',
                    'O corretor é responsável por toda a informação publicada em seus anúncios e pelas negociações realizadas através da plataforma.',
                  ),
                ],
              ),
            ),
          ),
          // Secção inferior com a caixa de seleção e o botão
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text(
                    'Li e aceito os Termos e Condições.',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _termsAccepted,
                  onChanged: (newValue) {
                    setState(() {
                      _termsAccepted = newValue ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _termsAccepted ? _continueToVerification : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continuar para Verificação'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para formatar as secções dos termos
  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}