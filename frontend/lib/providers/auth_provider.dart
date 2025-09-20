import 'dart:convert';
import 'dart:io'; 
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
  Set<int> _favoriteIds = {}; // <-- NOVO: Estado para guardar os IDs dos favoritos
  final _storage = const FlutterSecureStorage();
  final String _apiUrl = 'http://10.0.2.2:3333';

  // Getters para o estado de autenticação
  bool get isAuthenticated => _token != null;
  User? get user => _user;
  String? get token => _token;

  // --- NOVOS GETTERS PARA FAVORITOS ---
  Set<int> get favoriteIds => _favoriteIds;
  bool isFavorite(int propertyId) => _favoriteIds.contains(propertyId);
  
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

      await _fetchFavorites(); // <-- NOVO: Busca os favoritos após o login
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    final storedUserData = await _storage.read(key: 'userData');
    if (storedToken == null || storedUserData == null) return false;
    
    final userData = json.decode(storedUserData);
    _token = storedToken;
    _user = User(
      id: userData['id'], name: userData['name'], email: userData['email'], role: userData['role'],
    );
    
    await _fetchFavorites(); // <-- NOVO: Busca os favoritos no auto-login
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _favoriteIds = {}; // <-- NOVO: Limpa os favoritos no logout
    await _storage.deleteAll();
    notifyListeners();
  }

  // --- NOVOS MÉTODOS PARA GERIR FAVORITOS ---

  Future<void> _fetchFavorites() async {
    if (!isAuthenticated) return;
    final url = Uri.parse('$_apiUrl/properties/user/favorites');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> favoriteProperties = json.decode(response.body);
        _favoriteIds = favoriteProperties.map((prop) => prop['id'] as int).toSet();
      } else {
        _favoriteIds = {};
      }
    } catch (error) {
      _favoriteIds = {};
      debugPrint('Erro ao buscar favoritos: $error');
    }
    // O notifyListeners() será chamado pela função que invocou esta (login/tryAutoLogin).
  }

  Future<void> toggleFavoriteStatus(int propertyId) async {
    if (!isAuthenticated) return;
    
    final isCurrentlyFavorite = isFavorite(propertyId);
    final url = Uri.parse('$_apiUrl/properties/$propertyId/favorite');

    // Atualização otimista da UI para uma resposta instantânea
    if (isCurrentlyFavorite) {
      _favoriteIds.remove(propertyId);
    } else {
      _favoriteIds.add(propertyId);
    }
    notifyListeners();

    try {
      final response = isCurrentlyFavorite
        ? await http.delete(url, headers: {'Authorization': 'Bearer $_token'})
        : await http.post(url, headers: {'Authorization': 'Bearer $_token'});

      // Se a API falhar, reverte a alteração na UI
      if ((isCurrentlyFavorite && response.statusCode != 200) ||
          (!isCurrentlyFavorite && response.statusCode != 201)) {
        if (isCurrentlyFavorite) {
          _favoriteIds.add(propertyId);
        } else {
          _favoriteIds.remove(propertyId);
        }
        notifyListeners();
      }
    } catch (error) {
      // Reverte a alteração em caso de qualquer exceção de rede
      if (isCurrentlyFavorite) {
        _favoriteIds.add(propertyId);
      } else {
        _favoriteIds.remove(propertyId);
      }
      notifyListeners();
      debugPrint('Erro ao alterar favorito: $error');
    }
  }
  Future<void> submitVerificationDocs({
    required File creciFront,
    required File creciBack,
    required File selfie,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Utilizador não autenticado.');
    }

    final url = Uri.parse('$_apiUrl/brokers/me/verify-documents');
    final request = http.MultipartRequest('POST', url);

    // Anexa o token de autenticação ao cabeçalho
    request.headers['Authorization'] = 'Bearer $_token';

    // Anexa cada ficheiro ao seu campo correspondente
    // Os nomes dos campos ('creciFront', 'creciBack', 'selfie') devem
    // corresponder exatamente ao que foi definido no multer no backend.
    request.files.add(await http.MultipartFile.fromPath(
      'creciFront',
      creciFront.path,
    ));
    request.files.add(await http.MultipartFile.fromPath(
      'creciBack',
      creciBack.path,
    ));
    request.files.add(await http.MultipartFile.fromPath(
      'selfie',
      selfie.path,
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['error'] ?? 'Falha ao enviar documentos.');
      }
    } catch (error) {
      debugPrint('Erro no upload de documentos: $error');
      rethrow;
    }
  }
}

