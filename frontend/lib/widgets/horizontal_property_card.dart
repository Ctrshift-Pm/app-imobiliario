import 'package:flutter/material.dart';
import '../models/property.dart';
import '../screens/property_detail_screen.dart';

class HorizontalPropertyCard extends StatelessWidget {
  final Property property;

  const HorizontalPropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determina qual URL de imagem usar, com base na nova lista de imagens
    final String displayImageUrl = property.images.isNotEmpty
        ? property.images.first
        : 'https://placehold.co/600x400/00a859/FFFFFF?text=Im%C3%B3vel';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          PropertyDetailScreen.routeName,
          arguments: property,
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                displayImageUrl, // Usa a URL de imagem correta
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              property.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'R\$ ${property.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

