// verification_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'tabs_screen.dart';

class VerificationScreen extends StatefulWidget {
  static const routeName = '/verification';
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  File? _creciFrontImage;
  File? _creciBackImage;
  File? _selfieWithCreciImage;

  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _registerData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtém os dados de registro passados como argumentos
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _registerData = args;
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File) onImagePicked) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        onImagePicked(File(pickedFile.path));
      });
    }
  }

  void _showImagePicker(Function(File) onImagePicked) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                _pickImage(ImageSource.gallery, onImagePicked);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmara'),
              onTap: () {
                _pickImage(ImageSource.camera, onImagePicked);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitVerification() async {
    if (_creciFrontImage == null || _creciBackImage == null || _selfieWithCreciImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, envie todas as três imagens.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Lógica para enviar as imagens para o backend usando o Provider
      await Provider.of<AuthProvider>(context, listen: false).registerBroker(
        _registerData!['authData'],
        _creciFrontImage!,
        _creciBackImage!,
        _selfieWithCreciImage!,
      );

      // Mostra uma mensagem de sucesso e navega
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documentos enviados com sucesso! Sua conta será verificada em breve.')),
        );
        Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar documentos: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação de Corretor'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                final isLastStep = _currentStep == 2;
                if (isLastStep) {
                  _submitVerification();
                } else {
                  setState(() => _currentStep += 1);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: [
                _buildStep(
                  title: 'Frente do CRECI',
                  content: _buildImagePicker(
                    imageFile: _creciFrontImage,
                    onTap: () => _showImagePicker((file) {
                      setState(() => _creciFrontImage = file);
                    }),
                  ),
                  isActive: _currentStep >= 0,
                ),
                _buildStep(
                  title: 'Verso do CRECI',
                  content: _buildImagePicker(
                    imageFile: _creciBackImage,
                    onTap: () => _showImagePicker((file) {
                      setState(() => _creciBackImage = file);
                    }),
                  ),
                  isActive: _currentStep >= 1,
                ),
                _buildStep(
                  title: 'Selfie com o Documento',
                  content: Column(
                    children: [
                      _buildImagePicker(
                        imageFile: _selfieWithCreciImage,
                        onTap: () => _showImagePicker((file) {
                          setState(() => _selfieWithCreciImage = file);
                        }),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Por favor, tire uma selfie segurando seu CRECI próximo ao seu rosto, '
                        'garantindo que tanto seu rosto quanto o documento estejam visíveis e legíveis.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
              ],
              controlsBuilder: (context, details) {
                final isLastStep = details.currentStep == 2;
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isLastStep ? 'ENVIAR PARA VERIFICAÇÃO' : 'CONTINUAR'),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('VOLTAR'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Step _buildStep({required String title, required Widget content, bool isActive = false}) {
    return Step(
      title: Text(title, style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
      )),
      content: content,
      isActive: isActive,
      state: _getStepState(title),
    );
  }

  StepState _getStepState(String title) {
    if (title == 'Frente do CRECI' && _creciFrontImage != null) {
      return StepState.complete;
    } else if (title == 'Verso do CRECI' && _creciBackImage != null) {
      return StepState.complete;
    } else if (title == 'Selfie com o Documento' && _selfieWithCreciImage != null) {
      return StepState.complete;
    }
    return StepState.indexed;
  }

  Widget _buildImagePicker({required File? imageFile, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: imageFile != null 
                  ? Colors.green
                  : Colors.grey.shade400, 
                width: 1.5
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      const Text('Clique para enviar uma imagem'),
                    ],
                  ),
          ),
        ),
        if (imageFile != null) 
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Imagem selecionada',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}