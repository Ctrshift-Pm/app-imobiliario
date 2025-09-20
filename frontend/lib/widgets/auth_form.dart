import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/tabs_screen.dart';
import '../screens/auth_landing_screen.dart';

class AuthForm extends StatefulWidget {
  final AuthMode authMode;
  final Role role;

  const AuthForm({required this.authMode, required this.role, super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
    'creci': '',
  };
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final userType = widget.role == Role.client ? 'user' : 'broker';

    try {
      if (widget.authMode == AuthMode.login) {
        await Provider.of<AuthProvider>(context, listen: false).login(_authData['email']!, _authData['password']!, userType);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
        }
      } else {
        await Provider.of<AuthProvider>(context, listen: false).register(_authData, userType);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registo efetuado com sucesso! Por favor, faça o login.'), backgroundColor: Colors.green),
          );
          // Idealmente, aqui voltaria para o modo de login
        }
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.authMode == AuthMode.register) ...[
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Nome Completo', labelStyle: TextStyle(color: Colors.white70)),
              validator: (value) => value!.isEmpty ? 'O nome é obrigatório.' : null,
              onSaved: (value) => _authData['name'] = value!,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white70)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@')) ? 'Email inválido.' : null,
            onSaved: (value) => _authData['email'] = value!,
          ),
          const SizedBox(height: 12),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Senha', labelStyle: TextStyle(color: Colors.white70)),
            obscureText: true,
            validator: (value) => (value == null || value.length < 6) ? 'A senha é muito curta.' : null,
            onSaved: (value) => _authData['password'] = value!,
          ),
          if (widget.authMode == AuthMode.register && widget.role == Role.broker) ...[
            const SizedBox(height: 12),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'CRECI', labelStyle: TextStyle(color: Colors.white70)),
              validator: (value) => (value!.isEmpty) ? 'O CRECI é obrigatório.' : null,
              onSaved: (value) => _authData['creci'] = value!,
            ),
          ],
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(widget.authMode == AuthMode.login ? 'Entrar' : 'Registar'),
            ),
        ],
      ),
    );
  }
}