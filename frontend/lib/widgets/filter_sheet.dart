import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedPurpose;
  String? _selectedType;
  String? _selectedCity;
  RangeValues _selectedPriceRange = const RangeValues(0, 2000000);
  final List<String> _propertyTypes = [
    'Casa',
    'Apartamento',
    'Terreno',
    'Propriedade Rural',
    'Propriedade Comercial'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchAvailableCities();
    });
  }

  void _applyFilters() {
    final filters = <String, String>{};
    if (_selectedPurpose != null) {
      filters['purpose'] = _selectedPurpose == 'Comprar' ? 'Venda' : 'Aluguel';
    }
    if (_selectedType != null) filters['type'] = _selectedType!;
    if (_selectedCity != null) filters['city'] = _selectedCity!;
    filters['minPrice'] = _selectedPriceRange.start.round().toString();
    filters['maxPrice'] = _selectedPriceRange.end.round().toString();

    Navigator.of(context).pop(filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedPurpose = null;
      _selectedType = null;
      _selectedCity = null;
      _selectedPriceRange = const RangeValues(0, 2000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableCities = Provider.of<PropertyProvider>(context).availableCities;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar Imóveis',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'Limpar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filtro: Comprar ou Alugar
                  _buildSectionTitle('Finalidade'),
                  Wrap(
                    spacing: 8,
                    children: ['Comprar', 'Alugar'].map((purpose) {
                      return FilterChip(
                        label: Text(purpose),
                        selected: _selectedPurpose == purpose,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPurpose = selected ? purpose : null;
                          });
                        },
                        selectedColor: theme.primaryColor,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedPurpose == purpose 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Filtro: Tipo de Imóvel
                  _buildSectionTitle('Tipo de Imóvel'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _propertyTypes.map((type) {
                      return FilterChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                        selectedColor: theme.primaryColor,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedType == type 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Filtro: Cidades
                  _buildSectionTitle('Cidade'),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    hint: const Text('Selecione uma cidade'),
                    onChanged: (value) => setState(() => _selectedCity = value),
                    items: availableCities
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filtro: Faixa de Preço
                  _buildSectionTitle('Faixa de Preço'),
                  Text(
                    'R\$ ${_selectedPriceRange.start.round()} - R\$ ${_selectedPriceRange.end.round()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // filter_sheet.dart - RangeSlider atualizado
                  RangeSlider(
                    values: _selectedPriceRange,
                    min: 0,
                    max: 10000000, // 10 milhões
                    divisions: 100,
                    labels: RangeLabels(
                      'R\$ ${_selectedPriceRange.start.round()}',
                      'R\$ ${_selectedPriceRange.end.round()}',
                    ),
                    onChanged: (values) => setState(() => _selectedPriceRange = values),
                    activeColor: theme.primaryColor,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Botão Aplicar
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aplicar Filtros',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}