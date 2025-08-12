import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../providers/property_provider.dart';
import '../screens/property_detail_screen.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({required this.property, super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos um Consumer aqui para que apenas o ícone se reconstrua ao ser tocado
    return Consumer<PropertyProvider>(
      builder: (ctx, propertyProvider, child) => GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            PropertyDetailScreen.routeName,
            arguments: property,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.network(
                      'https://placehold.co/600x400/00a859/white?text=${property.type}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[300], child: const Icon(Icons.house, size: 80, color: Colors.grey));
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.type.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(property.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(child: Text('${property.address}, ${property.city}', style: TextStyle(color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('R\$ ${property.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                            Row(
                              children: [
                                if (property.bedrooms != null) ...[
                                  Icon(Icons.king_bed, size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${property.bedrooms}'),
                                  const SizedBox(width: 16),
                                ],
                                if (property.bathrooms != null) ...[
                                  Icon(Icons.bathtub, size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${property.bathrooms}'),
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
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      propertyProvider.isFavorite(property.id) ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      propertyProvider.toggleFavoriteStatus(property.id);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}