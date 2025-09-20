import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  var _editedProperty = Property(
    id: 0,
    title: '',
    description: '',
    type: 'Apartamento',
    status: 'Disponível',
    purpose: 'Venda',
    price: 0.0,
    address: '',
    city: '',
    images: [],
    bedrooms: null,
    bathrooms: null,
    area: null,
    brokerId: null,
    hasWifi: false,
    garageSpots: null,
    state: 'GO',
    createdAt: DateTime.now(),
  );

  bool _isLoading = false;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final maxImagesToPick = 25 - _selectedImages.length;
    if (maxImagesToPick <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você já atingiu o limite de 25 imagens.')),
      );
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(
          pickedFiles.map((file) => File(file.path)).take(maxImagesToPick)
        );
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveForm() async {
  if (_selectedImages.length < 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, selecione pelo menos 2 imagens.')),
    );
    return;
  }

  final isValid = _formKey.currentState!.validate();
  if (!isValid) return;
  
  _formKey.currentState!.save();
  setState(() => _isLoading = true);

  try {
    await Provider.of<PropertyProvider>(context, listen: false).addProperty(
      _editedProperty, 
      _selectedImages
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imóvel adicionado com sucesso!')),
      );
      Navigator.of(context).pop();
    }
  } catch (error) {
    if (mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: Text('Erro: $error'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    }
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
                    // Seção de imagens
                    const Text('Imagens do Imóvel (mín. 2, máx. 25)', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _selectedImages.isEmpty
                          ? const Center(child: Text('Nenhuma imagem selecionada.'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _selectedImages.length,
                              itemBuilder: (ctx, index) => Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Adicionar Imagens'),
                      onPressed: _pickImages,
                    ),
                    const SizedBox(height: 24),
                    
                    // Campos do formulário
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Título'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça um título.' : null,
                      onSaved: (value) {
                        _editedProperty = _editedProperty.copyWith(title: value);
                      },
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
                      onSaved: (value) {
                        _editedProperty = _editedProperty.copyWith(price: double.parse(value!));
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _editedProperty.type,
                            decoration: const InputDecoration(labelText: 'Tipo'),
                            items: ['Casa', 'Apartamento', 'Terreno'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _editedProperty = _editedProperty.copyWith(type: newValue);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _editedProperty.purpose,
                            decoration: const InputDecoration(labelText: 'Finalidade'),
                            items: ['Venda', 'Aluguel'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _editedProperty = _editedProperty.copyWith(purpose: newValue);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Endereço'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça um endereço.' : null,
                      onSaved: (value) {
                        _editedProperty = _editedProperty.copyWith(address: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça uma cidade.' : null,
                      onSaved: (value) {
                        _editedProperty = _editedProperty.copyWith(city: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Quartos'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) {
                              _editedProperty = _editedProperty.copyWith(bedrooms: int.tryParse(value ?? ''));
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Casas de Banho'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) {
                              _editedProperty = _editedProperty.copyWith(bathrooms: int.tryParse(value ?? ''));
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Área (m²)'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) {
                              _editedProperty = _editedProperty.copyWith(area: int.tryParse(value ?? ''));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Espaços na Garagem'),
                            keyboardType: TextInputType.number,
                            initialValue: '0',
                            onSaved: (value) {
                              _editedProperty = _editedProperty.copyWith(garageSpots: int.tryParse(value ?? '0') ?? 0);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Wi-Fi'),
                            value: _editedProperty.hasWifi,
                            onChanged: (value) {
                              setState(() {
                                _editedProperty = _editedProperty.copyWith(hasWifi: value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      validator: (value) => value!.isEmpty ? 'Por favor, forneça uma descrição.' : null,
                      onSaved: (value) {
                        _editedProperty = _editedProperty.copyWith(description: value);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}