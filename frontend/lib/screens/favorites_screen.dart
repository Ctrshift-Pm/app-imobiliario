import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
import '../models/property.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Acede ao provider para obter os dados
    final propertyProvider = Provider.of<PropertyProvider>(context);

    // CORREÇÃO: Usa o getter 'favoriteProperties' que já contém a lista filtrada
    final List<Property> favoriteProperties = propertyProvider.favoriteProperties;

    // A AppBar foi removida porque o TabsScreen já a providencia
    return Scaffold(
      body: favoriteProperties.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Você ainda não tem imóveis favoritos.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Clique no coração para guardar os que mais gostar!',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteProperties.length,
              itemBuilder: (ctx, index) {
                return PropertyCard(property: favoriteProperties[index]);
              },
            ),
    );
  }
}

