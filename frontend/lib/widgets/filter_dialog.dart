import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final Function(Map<String, String>) onApplyFilters;
  final Map<String, String> currentFilters;

  const FilterDialog({
    required this.onApplyFilters,
    required this.currentFilters,
    super.key
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _type;
  String? _purpose;
  late TextEditingController _cityController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _type = widget.currentFilters['type'];
    _purpose = widget.currentFilters['purpose'];
    _cityController = TextEditingController(text: widget.currentFilters['city']);
    _minPriceController = TextEditingController(text: widget.currentFilters['minPrice']);
    _maxPriceController = TextEditingController(text: widget.currentFilters['maxPrice']);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _submitFilters() {
    final Map<String, String> filters = {};
    if (_type != null) filters['type'] = _type!;
    if (_purpose != null) filters['purpose'] = _purpose!;
    if (_cityController.text.isNotEmpty) filters['city'] = _cityController.text;
    if (_minPriceController.text.isNotEmpty) filters['minPrice'] = _minPriceController.text;
    if (_maxPriceController.text.isNotEmpty) filters['maxPrice'] = _maxPriceController.text;
    
    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    widget.onApplyFilters({}); 
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros Avançados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Limpar Tudo'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitFilters,
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}