import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../providers/property_provider.dart';

class AddPropertyScreen extends StatefulWidget {
  static const routeName = '/add-property';
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'title': '',
    'description': '',
    'type': 'Apartamento',
    'purpose': 'Venda',
    'price': 0.0,
    'address': '',
    'city': '',
    'bedrooms': null,
    'bathrooms': null,
    'area': null,
    'garage_spots': 0,
    'has_wifi': false,
    'video_url': '',
  };
  bool _isLoading = false;

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final newProperty = Property(
      id: 0,
      title: _formData['title'],
      description: _formData['description'],
      type: _formData['type'],
      status: 'Disponível',
      purpose: _formData['purpose'],
      price: _formData['price'],
      address: _formData['address'],
      city: _formData['city'],
      bedrooms: _formData['bedrooms'],
      bathrooms: _formData['bathrooms'],
      area: _formData['area'],
      garageSpots: _formData['garage_spots'],
      hasWifi: _formData['has_wifi'],
      imageUrl: _formData['image_url'],
    );

    try {
      await Provider.of<PropertyProvider>(context, listen: false).addProperty(newProperty);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Algo correu mal ao guardar o imóvel.'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Imóvel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Título'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça um título.' : null,
                      onSaved: (value) => _formData['title'] = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) return 'Por favor, forneça um preço.';
                        if (double.tryParse(value) == null) return 'Por favor, insira um número válido.';
                        if (double.parse(value) <= 0) return 'Por favor, insira um preço positivo.';
                        return null;
                      },
                      onSaved: (value) => _formData['price'] = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formData['type'],
                            decoration: const InputDecoration(labelText: 'Tipo'),
                            items: ['Casa', 'Apartamento', 'Terreno'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (newValue) => setState(() => _formData['type'] = newValue!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formData['purpose'],
                            decoration: const InputDecoration(labelText: 'Finalidade'),
                            items: ['Venda', 'Aluguel'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (newValue) => setState(() => _formData['purpose'] = newValue!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Endereço'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça um endereço.' : null,
                      onSaved: (value) => _formData['address'] = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça uma cidade.' : null,
                      onSaved: (value) => _formData['city'] = value!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Quartos'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) => _formData['bedrooms'] = int.tryParse(value ?? ''),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Casas de Banho'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) => _formData['bathrooms'] = int.tryParse(value ?? ''),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Área (m²)'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) => _formData['area'] = int.tryParse(value ?? ''),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                     Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Vagas Garagem'),
                            keyboardType: TextInputType.number,
                            initialValue: '0',
                            onSaved: (value) => _formData['garage_spots'] = int.tryParse(value ?? '0') ?? 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Wi-Fi'),
                            value: _formData['has_wifi'],
                            onChanged: (value) {
                              setState(() {
                                _formData['has_wifi'] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'URL do Vídeo (Opcional)'),
                      keyboardType: TextInputType.url,
                      onSaved: (value) => _formData['video_url'] = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça uma descrição.' : null,
                      onSaved: (value) => _formData['description'] = value!,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}