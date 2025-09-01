import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../providers/property_provider.dart';
import '../screens/property_detail_screen.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({required this.property, super.key});

  // Placeholder image if no image is available
  static const String _placeholderImageUrl = 'https://via.placeholder.com/600x400/00a859/FFFFFF?text=Sem+Imagem';

  @override
  Widget build(BuildContext context) {
    // Wrap with Consumer to react to changes in PropertyProvider (for favorite status)
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Property Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        property.imageUrl?.isNotEmpty == true ? property.imageUrl! : _placeholderImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.house, size: 80, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 18,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          propertyProvider.isFavorite(property.id) ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                        onPressed: () {
                          propertyProvider.toggleFavoriteStatus(property.id);
                        },
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
                    // Property Type
                    Text(
                      property.type.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Property Title
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.city,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${property.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            if (property.bedrooms != null && property.bedrooms! > 0) ...[
                              Icon(Icons.king_bed, size: 18, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 2),
                              Text('${property.bedrooms}', style: TextStyle(color: Colors.grey[800])),
                              const SizedBox(width: 12),
                            ],
                            if (property.bathrooms != null && property.bathrooms! > 0) ...[
                              Icon(Icons.bathtub, size: 18, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 2),
                              Text('${property.bathrooms}', style: TextStyle(color: Colors.grey[800])),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}