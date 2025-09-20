import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide Image;

import '../models/property.dart';
import '../providers/auth_provider.dart';
import '../screens/property_detail_screen.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final Function(int)? onDelete; // <-- NOVO: Callback opcional para exclusão

  const PropertyCard({
    Key? key,
    required this.property,
    this.onDelete, // <-- NOVO: Parâmetro no construtor
  }) : super(key: key);

  @override
  PropertyCardState createState() => PropertyCardState();
}

class PropertyCardState extends State<PropertyCard> {
  SMIBool? _isLikedInput;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _isLikedInput = controller.findInput<bool>('isLiked') as SMIBool;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isLikedInput?.value = authProvider.isFavorite(widget.property.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, _) {
        _isLikedInput?.value = authProvider.isFavorite(widget.property.id);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              PropertyDetailScreen.routeName,
              arguments: widget.property,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          widget.property.images.isNotEmpty
                              ? widget.property.images.first
                              : 'https://placehold.co/600x400/00a859/FFFFFF?text=Sem+Imagem',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[300], child: const Icon(Icons.house, size: 80, color: Colors.grey)),
                        ),
                      ),
                    ),
                    // Botão de Favoritar (canto superior direito)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => authProvider.toggleFavoriteStatus(widget.property.id),
                        child: Container(
                          width: 50, height: 50,
                          decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.4), shape: BoxShape.circle),
                          child: RiveAnimation.asset('assets/animations/interactive_like_button_animation.riv', onInit: _onRiveInit),
                        ),
                      ),
                    ),
                    // --- NOVO BOTÃO DE EXCLUSÃO (canto superior esquerdo) ---
                    // Só aparece se a função onDelete for fornecida
                    if (widget.onDelete != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                           width: 40, height: 40,
                           decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.4), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.white, size: 22),
                            onPressed: () => widget.onDelete!(widget.property.id),
                            tooltip: 'Excluir Imóvel',
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.property.type.toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text(widget.property.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(child: Text('${widget.property.address}, ${widget.property.city}', style: TextStyle(color: Colors.grey[600], fontSize: 14), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('R\$ ${widget.property.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                          Row(
                            children: [
                              if (widget.property.bedrooms != null && widget.property.bedrooms! > 0) ...[
                                Icon(Icons.king_bed, size: 18, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 4),
                                Text('${widget.property.bedrooms}', style: TextStyle(color: Colors.grey[800])),
                                const SizedBox(width: 12),
                              ],
                              if (widget.property.bathrooms != null && widget.property.bathrooms! > 0) ...[
                                Icon(Icons.bathtub, size: 18, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 4),
                                Text('${widget.property.bathrooms}', style: TextStyle(color: Colors.grey[800])),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
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

