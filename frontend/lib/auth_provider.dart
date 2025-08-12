import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  User({required this.id, required this.name, required this.email, required this.role});
}

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  final _storage = const FlutterSecureStorage();
  final String _apiUrl = 'http://10.0.2.2:3333'; 

  bool get isAuthenticated => _token != null;
  User? get user => _user;
  String? get token => _token;

  Future<void> register(Map<String, String> authData, String userType) async {
    final endpoint = userType == 'user' ? 'users' : 'brokers';
    final url = Uri.parse('$_apiUrl/$endpoint/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 201) {
        throw Exception(responseData['error'] ?? 'Ocorreu um erro.');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(String email, String password, String userType) async {
    final endpoint = userType == 'user' ? 'users' : 'brokers';
    final url = Uri.parse('$_apiUrl/$endpoint/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['error'] ?? 'Ocorreu um erro.');
      }
      _token = responseData['token'];
      final userData = responseData[userType];
      _user = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        role: userType,
      );
      await _storage.write(key: 'authToken', value: _token);
      await _storage.write(key: 'userData', value: json.encode({
        'id': _user!.id, 'name': _user!.name, 'email': _user!.email, 'role': _user!.role,
      }));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    final storedUserData = await _storage.read(key: 'userData');
    if (storedToken == null || storedUserData == null) return false;
    
    // TODO: Adicionar validação do token (verificar expiração)
    final userData = json.decode(storedUserData);
    _token = storedToken;
    _user = User(
      id: userData['id'], name: userData['name'], email: userData['email'], role: userData['role'],
    );
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}