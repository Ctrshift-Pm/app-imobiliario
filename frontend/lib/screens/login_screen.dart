import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/logo_widget.dart'; // NOVO

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  int _selectedUserTypeIndex = 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);

    try {
      final userType = _selectedUserTypeIndex == 0 ? 'user' : 'broker';
      await Provider.of<AuthProvider>(context, listen: false).login(_email, _password, userType);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const LogoWidget(height: 100), // CORRIGIDO
                  const SizedBox(height: 24),
                  const Text(
                    'ConectImóvel',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Encontre o seu lugar ideal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  ToggleButtons(
                    isSelected: [_selectedUserTypeIndex == 0, _selectedUserTypeIndex == 1],
                    onPressed: (index) => setState(() => _selectedUserTypeIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: theme.primaryColor,
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Cliente')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Corretor')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Email inválido.' : null,
                    onSaved: (value) => _email = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6) ? 'A senha é muito curta.' : null,
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Entrar'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
