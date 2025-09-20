import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide Image, LinearGradient; // Esconde as classes em conflito
import 'package:url_launcher/url_launcher.dart';

import '../models/property.dart';
import '../providers/auth_provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  static const routeName = '/property-detail';
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Property property;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  SMIBool? _isLikedInput;

  // Função para inicializar o controlador da animação Rive
  void _onRiveInit(Artboard artboard, Property currentProperty) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _isLikedInput = controller.findInput<bool>('isLiked') as SMIBool;

    // Sincroniza o estado inicial da animação com o estado do provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isLikedInput?.value = authProvider.isFavorite(currentProperty.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtém o objeto Property completo que foi passado como argumento da rota
    property = ModalRoute.of(context)!.settings.arguments as Property;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '+5562999998888'; // Número de exemplo
    final message = 'Olá! Tenho interesse no imóvel "${property.title}".';
    final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.user?.role == 'broker' && authProvider.user?.id == property.brokerId;

    return Scaffold(
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () { /* Lógica para editar status */ },
              label: const Text('Editar Status'),
              icon: const Icon(Icons.edit),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
            )
          : FloatingActionButton.extended(
              onPressed: _launchWhatsApp,
              label: const Text('Contactar via WhatsApp'),
              icon: const Icon(Icons.chat),
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  // Sincroniza a animação com o estado atual do provider
                  _isLikedInput?.value = auth.isFavorite(property.id);
                  return GestureDetector(
                    onTap: () {
                      auth.toggleFavoriteStatus(property.id);
                    },
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: RiveAnimation.asset(
                        'assets/animations/interactive_like_button_animation.riv',
                        onInit: (artboard) => _onRiveInit(artboard, property),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: property.images.isNotEmpty ? property.images.length : 1,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = property.images.isNotEmpty
                          ? property.images[index]
                          : 'https://placehold.co/600x400/00a859/white?text=Sem+Imagem';
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.house_siding, size: 150, color: Colors.grey),
                          );
                        },
                      );
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient( // Corrigido: 'LinearGradient' é um construtor
                        begin: const Alignment(0.0, 0.8),
                        end: Alignment.topCenter,
                        colors: <Color>[
                          const Color(0x60000000),
                          const Color(0x00000000)
                        ],
                      ),
                    ),
                  ),
                  if (property.images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(property.images.length, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Corrigido: deprecated 'withOpacity'
                              color: _currentPage == index ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(property.status),
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(property.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('R\$ ${property.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                      const Divider(height: 48),
                      const Text('Descrição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(property.description, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5)),
                      const Divider(height: 48),
                      const Text('Detalhes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                           // Corrigido: Adicionado verificação de nulo
                          if (property.bedrooms! > 0) _buildDetailItem(Icons.king_bed_outlined, '${property.bedrooms}', 'Quartos'),
                          if (property.bathrooms! > 0) _buildDetailItem(Icons.bathtub_outlined, '${property.bathrooms}', 'Banheiros'),
                          if (property.area! > 0) _buildDetailItem(Icons.square_foot_outlined, '${property.area} m²', 'Área'),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[800]),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

