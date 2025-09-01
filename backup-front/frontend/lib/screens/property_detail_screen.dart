import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';

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

  final List<String> _imageUrls = [
    'https://placehold.co/600x400/00a859/white?text=Fachada',
    'https://placehold.co/600x400/cccccc/666666?text=Sala',
    'https://placehold.co/600x400/cccccc/666666?text=Cozinha',
    'https://placehold.co/600x400/cccccc/666666?text=Quarto',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    property = ModalRoute.of(context)!.settings.arguments as Property;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '+5562999998888'; // Número de telefone fictício
    final message = 'Olá! Tenho interesse no imóvel "${property.title}".';
    final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      // Mostra um erro se não conseguir abrir o WhatsApp
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    }
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        // Usa um StatefulWidget dentro do diálogo para gerir o estado do dropdown
        String selectedStatus = property.status;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Alterar Status do Imóvel'),
              content: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: ['Disponível', 'Negociando', 'Vendido', 'Alugado']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: const Text('Salvar'),
                  onPressed: () {
                    Provider.of<PropertyProvider>(context, listen: false)
                        .updatePropertyStatus(property.id, selectedStatus);
                    // Atualiza o estado do ecrã principal
                    setState(() {
                      property.status = selectedStatus;
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Acessa o brokerId da propriedade que foi passada para este ecrã
    final brokerIdFromProperty = (ModalRoute.of(context)!.settings.arguments as Property).brokerId;
    // Verifica se o utilizador logado é o corretor dono do imóvel
    final isOwner = authProvider.user?.role == 'broker' && authProvider.user?.id == brokerIdFromProperty;

    return Scaffold(
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: _showStatusUpdateDialog,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        _imageUrls[index],
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
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.8),
                        end: Alignment.topCenter,
                        colors: <Color>[Color(0x60000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                   Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_imageUrls.length, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
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
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(child: Text('${property.address}, ${property.city}', style: TextStyle(fontSize: 16, color: Colors.grey[700]))),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                          if (property.bedrooms != null) _buildDetailItem(Icons.king_bed_outlined, '${property.bedrooms}', 'Quartos'),
                          if (property.bathrooms != null) _buildDetailItem(Icons.bathtub_outlined, '${property.bathrooms}', 'Banheiros'),
                          if (property.area != null) _buildDetailItem(Icons.square_foot_outlined, '${property.area} m²', 'Área'),
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
