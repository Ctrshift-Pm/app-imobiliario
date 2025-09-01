import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/filter_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, String> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    if (mounted) setState(() => _isLoading = true);
    await Provider.of<PropertyProvider>(context, listen: false).fetchProperties(filters: _currentFilters);
    if (mounted) setState(() => _isLoading = false);
  }

  void _applyFilters(Map<String, String> newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    _fetchProperties();
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          currentFilters: _currentFilters,
          onApplyFilters: _applyFilters,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Row(
              children: [
                // A barra de pesquisa pode ser adicionada aqui no futuro
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar imóveis...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton.filled(
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: _showFilterDialog,
                ),
              ],
            )
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchProperties,
                    child: propertyProvider.properties.isEmpty
                        ? const Center(child: Text('Nenhum imóvel encontrado.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: propertyProvider.properties.length,
                            itemBuilder: (ctx, i) => PropertyCard(property: propertyProvider.properties[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}