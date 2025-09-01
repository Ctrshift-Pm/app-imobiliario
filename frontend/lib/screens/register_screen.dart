import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
    'creci': '',
  };
  bool _isLoading = false;
  int _selectedUserTypeIndex = 0; // 0 para Cliente, 1 para Corretor

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    
    final userType = _selectedUserTypeIndex == 0 ? 'user' : 'broker';
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).register(_authData, userType);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registo efetuado com sucesso! Pode agora fazer o login.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Volta para o ecrã de boas-vindas
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.redAccent),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Criar Conta', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                ToggleButtons(
                  isSelected: [_selectedUserTypeIndex == 0, _selectedUserTypeIndex == 1],
                  onPressed: (index) => setState(() => _selectedUserTypeIndex = index),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: theme.primaryColor,
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Sou Cliente')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Sou Corretor')),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                  validator: (value) => (value!.isEmpty) ? 'O nome é obrigatório.' : null,
                  onSaved: (value) => _authData['name'] = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Email inválido.' : null,
                  onSaved: (value) => _authData['email'] = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'A senha é muito curta.' : null,
                  onSaved: (value) => _authData['password'] = value!,
                ),
                if (_selectedUserTypeIndex == 1) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'CRECI'),
                    validator: (value) => (value!.isEmpty) ? 'O CRECI é obrigatório para corretores.' : null,
                    onSaved: (value) => _authData['creci'] = value!,
                  ),
                ],
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(onPressed: _submit, child: const Text('Registar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}