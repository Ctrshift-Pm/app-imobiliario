import 'package:flutter/material.dart';

class FilterPanel extends StatefulWidget {
  final Function(Map<String, String>) onApplyFilters;

  const FilterPanel({required this.onApplyFilters, super.key});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  String? _type;
  String? _purpose;
  final _cityController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  void _submitFilters() {
    final Map<String, String> filters = {};
    if (_type != null) filters['type'] = _type!;
    if (_purpose != null) filters['purpose'] = _purpose!;
    if (_cityController.text.isNotEmpty) filters['city'] = _cityController.text;
    if (_minPriceController.text.isNotEmpty) filters['minPrice'] = _minPriceController.text;
    if (_maxPriceController.text.isNotEmpty) filters['maxPrice'] = _maxPriceController.text;
    
    widget.onApplyFilters(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: ['Casa', 'Apartamento', 'Terreno'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) => setState(() => _type = newValue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _purpose,
                  decoration: const InputDecoration(labelText: 'Finalidade'),
                  items: ['Venda', 'Aluguel'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) => setState(() => _purpose = newValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Cidade'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(labelText: 'Preço Mínimo'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(labelText: 'Preço Máximo'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitFilters,
            child: const Text('Aplicar Filtros'),
          ),
        ],
      ),
    );
  }
}