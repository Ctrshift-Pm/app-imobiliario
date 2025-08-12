import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProperties = Provider.of<PropertyProvider>(context).favoriteProperties;

    return Scaffold(
      body: favoriteProperties.isEmpty
          ? const Center(
              child: Text('Você ainda não adicionou nenhum imóvel aos favoritos.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteProperties.length,
              itemBuilder: (ctx, i) => PropertyCard(property: favoriteProperties[i]),
            ),
    );
  }
}