import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/horizontal_property_card.dart';
import '../widgets/filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHomepageData();
  }

  Future<void> _loadHomepageData() async {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    
    try {
      await provider.fetchHomepageLists();
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erro ao carregar imóveis. Tente novamente.';
      });
    }
  }

  void openFilterSheet() async {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    
    final filters = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const FilterSheet(),
    );

    if (filters != null && mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      try {
        await provider.fetchFilteredProperties(filters);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Erro ao aplicar filtros. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });
          
          try {
            if (propertyProvider.isFilteredMode) {
              await propertyProvider.fetchFilteredProperties({});
            } else {
              await propertyProvider.fetchHomepageLists();
            }
            setState(() {
              _isLoading = false;
            });
          } catch (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'Erro ao atualizar. Tente novamente.';
            });
          }
        },
        child: _buildBody(propertyProvider),
      ),
    );
  }

  Widget _buildBody(PropertyProvider provider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHomepageData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (provider.isFilteredMode) {
      if (provider.filteredProperties.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Nenhum imóvel encontrado para estes filtros.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Provider.of<PropertyProvider>(context, listen: false).clearFilters();
                  _loadHomepageData();
                },
                child: const Text('Voltar para todos os imóveis'),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.filteredProperties.length,
        itemBuilder: (_, i) => PropertyCard(property: provider.filteredProperties[i]),
      );
    }

    // Verifica se todas as listas estão vazias
    if (provider.highestPriceProperties.isEmpty &&
        provider.lowestPriceProperties.isEmpty &&
        provider.recentProperties.isEmpty) {
      return const Center(
        child: Text('Nenhum imóvel disponível no momento.'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCarousel('Destaques', provider.highestPriceProperties),
          _buildCarousel('Oportunidades', provider.lowestPriceProperties),
          _buildCarousel('Adicionados Recentemente', provider.recentProperties),
        ],
      ),
    );
  }

  Widget _buildCarousel(String title, List<Property> properties) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: properties.length,
            itemBuilder: (ctx, i) => HorizontalPropertyCard(property: properties[i]),
          ),
        ),
      ],
    );
  }
}