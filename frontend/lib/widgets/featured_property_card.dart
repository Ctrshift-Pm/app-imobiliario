import 'package:flutter/material.dart';
import '../models/property.dart';
import '../screens/property_detail_screen.dart';

class FeaturedPropertyCard extends StatelessWidget {
  final Property property;
  const FeaturedPropertyCard({required this.property, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          PropertyDetailScreen.routeName,
          arguments: property,
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  'https://placehold.co/600x400/00a859/white?text=${property.type}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              property.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(property.city, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'R\$ ${property.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}