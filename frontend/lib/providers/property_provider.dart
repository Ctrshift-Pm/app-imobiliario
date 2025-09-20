import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class PropertyProvider with ChangeNotifier {
  // Listas para a Home Screen
  List<Property> _highestPriceProperties = [];
  List<Property> _lowestPriceProperties = [];
  List<Property> _recentProperties = [];
  
  // Lista para os resultados de filtros
  List<Property> _filteredProperties = [];
  
  // Listas para funcionalidades do utilizador
  List<Property> _myProperties = [];
  final List<int> _favoritePropertyIds = [];
  List<String> _availableCities = [];
  
  // Estados de carregamento
  bool _isLoading = true;
  bool _isFilteredMode = false; // Controla qual vista mostrar na Home
  
  final String? _authToken;
  final String _baseUrl = 'http://10.0.2.2:3333';

  PropertyProvider(this._authToken) {
    // Busca os dados públicos independentemente do login
    fetchHomepageLists();
    fetchAvailableCities();
    
    if (_authToken != null) {
      fetchFavoritePropertyIds();
      fetchMyProperties();
    }
  }

  // Getters
  List<Property> get highestPriceProperties => [..._highestPriceProperties];
  List<Property> get lowestPriceProperties => [..._lowestPriceProperties];
  List<Property> get recentProperties => [..._recentProperties];
  List<Property> get filteredProperties => [..._filteredProperties];
  List<Property> get myProperties => [..._myProperties];
  List<Property> get favoriteProperties => 
      [..._highestPriceProperties, ..._lowestPriceProperties, ..._recentProperties, ..._filteredProperties, ..._myProperties]
          .toSet() // Usa toSet() para remover duplicados de forma eficiente
          .where((prop) => _favoritePropertyIds.contains(prop.id))
          .toList();
  List<String> get availableCities => [..._availableCities];
  bool get isLoading => _isLoading;
  bool get isFilteredMode => _isFilteredMode;

  bool isFavorite(int propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  // Busca uma lista específica de imóveis
  Future<List<Property>> _fetchPropertyList(Map<String, String> params) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties/public').replace(queryParameters: params);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Property.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Erro ao buscar lista de imóveis: $e");
    }
    return [];
  }

  // Busca as três listas para a Home
  Future<void> fetchHomepageLists() async {
    _isLoading = true;
    _isFilteredMode = false;
    notifyListeners();

    try {
      // Busca as três listas em paralelo para maior eficiência
      final results = await Future.wait([
        _fetchPropertyList({'sortBy': 'price', 'order': 'DESC', 'limit': '10'}),
        _fetchPropertyList({'sortBy': 'price', 'order': 'ASC', 'limit': '10'}),
        _fetchPropertyList({'sortBy': 'created_at', 'order': 'DESC', 'limit': '10'}),
      ]);

      _highestPriceProperties = results[0];
      _lowestPriceProperties = results[1];
      _recentProperties = results[2];
    } catch (e) {
      debugPrint("Erro ao buscar listas da homepage: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Busca imóveis com base nos filtros do utilizador
  // property_provider.dart - fetchFilteredProperties
Future<void> fetchFilteredProperties(Map<String, String> filters) async {
  _isLoading = true;
  _isFilteredMode = true;
  notifyListeners();

  try {
    final uri = Uri.parse('$_baseUrl/properties/public').replace(
      queryParameters: {
        ...filters,
        'page': '1',
        'limit': '50',
      },
    );
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _filteredProperties = (responseData['properties'] as List)
          .map((item) => Property.fromJson(item))
          .toList();
    }
  } catch (e) {
    debugPrint("Erro ao buscar imóveis filtrados: $e");
    _filteredProperties = [];
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  
  // Busca a lista de cidades disponíveis
  Future<void> fetchAvailableCities() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/properties/cities'));
      if (response.statusCode == 200) {
        final List<dynamic> cityData = json.decode(response.body);
        _availableCities = cityData.map((city) => city.toString()).toList();
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Erro ao buscar cidades: $error');
    }
  }

  // Busca os IDs dos imóveis favoritos do usuário
  Future<void> fetchFavoritePropertyIds() async {
    if (_authToken == null) return;
    
    // ATENÇÃO: Verifique se o endpoint no seu backend é '/users/me/favorites' ou '/properties/user/favorites'
    final url = Uri.parse('$_baseUrl/properties/user/favorites'); 
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_authToken'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> favoriteData = json.decode(response.body);
        _favoritePropertyIds.clear();
        // A API de favoritos retorna a lista de imóveis, então extraímos o ID
        _favoritePropertyIds.addAll(favoriteData.map<int>((item) => item['id']).toList());
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error fetching favorites: $error');
    }
  }

  // Alterna o status de favorito de um imóvel
  Future<void> toggleFavoriteStatus(int propertyId) async {
    if (_authToken == null) return;
    
    // ATENÇÃO: Verifique se o endpoint no backend é '/favoritar' ou '/favorite'
    final url = Uri.parse('$_baseUrl/properties/$propertyId/favorite');
    final wasFavorite = isFavorite(propertyId);
    
    try {
      // Atualização otimista da UI
      if (wasFavorite) {
        _favoritePropertyIds.remove(propertyId);
      } else {
        _favoritePropertyIds.add(propertyId);
      }
      notifyListeners();

      if (wasFavorite) {
        await http.delete(
          url,
          headers: {'Authorization': 'Bearer $_authToken'},
        );
      } else {
        await http.post(
          url,
          headers: {'Authorization': 'Bearer $_authToken'},
        );
      }
    } catch (error) {
      // Reverte em caso de erro de rede
      if (wasFavorite) {
        _favoritePropertyIds.add(propertyId);
      } else {
        _favoritePropertyIds.remove(propertyId);
      }
      notifyListeners();
      rethrow;
    }
  }
Future<void> fetchMyProperties() async {
  if (_authToken == null) return;
  
  final url = Uri.parse('$_baseUrl/brokers/me/properties');
  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $_authToken'},
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      // Verifica diferentes formatos de resposta
      if (responseData is Map<String, dynamic>) {
        if (responseData['success'] == true && responseData.containsKey('data')) {
          final List<dynamic> propertiesData = responseData['data'];
          _myProperties = propertiesData.map((item) => Property.fromJson(item)).toList();
        } else if (responseData.containsKey('properties')) {
          // Formato alternativo: {properties: [...]}
          final List<dynamic> propertiesData = responseData['properties'];
          _myProperties = propertiesData.map((item) => Property.fromJson(item)).toList();
        } else {
          // Formato direto: [...]
          _myProperties = (responseData as List).map((item) => Property.fromJson(item)).toList();
        }
      } else if (responseData is List) {
        // Resposta é uma lista direta
        _myProperties = responseData.map((item) => Property.fromJson(item)).toList();
      }
      
      notifyListeners();
    } else if (response.statusCode == 403) {
      // Usuário não é corretor - não é um erro, apenas não tem propriedades
      _myProperties = [];
      notifyListeners();
    } else {
      throw Exception('Falha ao carregar os seus imóveis. Código: ${response.statusCode}');
    }
  } catch (error) {
    debugPrint('Erro detalhado em fetchMyProperties: $error');
    // Não lançar exceção para evitar quebras na UI
    _myProperties = [];
    notifyListeners();
  }
}

  // Adiciona um novo imóvel
  // property_provider.dart
Future<void> addProperty(Property property, List<File> imageFiles) async {
  if (_authToken == null) return;
  
  try {
    // Upload das imagens para o Cloudinary primeiro
    final List<String> imageUrls = [];
    for (final imageFile in imageFiles) {
      final imageUrl = await _uploadImageToCloudinary(imageFile);
      imageUrls.add(imageUrl);
    }

    final url = Uri.parse('$_baseUrl/properties');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_authToken';
    
    // Adicionar campos de texto
    request.fields['title'] = property.title;
    request.fields['description'] = property.description;
    request.fields['type'] = property.type;
    request.fields['purpose'] = property.purpose;
    request.fields['price'] = property.price.toString();
    request.fields['address'] = property.address;
    request.fields['city'] = property.city;
    request.fields['state'] = property.state;
    request.fields['bedrooms'] = property.bedrooms?.toString() ?? '0';
    request.fields['bathrooms'] = property.bathrooms?.toString() ?? '0';
    request.fields['area'] = property.area?.toString() ?? '0';
    request.fields['garage_spots'] = property.garageSpots.toString();
    request.fields['has_wifi'] = property.hasWifi ? '1' : '0';
    
    // Adicionar arquivos de imagem
    for (final imageFile in imageFiles) {
      final fileStream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'images',
        fileStream,
        length,
        filename: imageFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Falha ao adicionar imóvel.');
    }
    
    // Atualizar listas
    await fetchMyProperties();
    await fetchHomepageLists();
  } catch (error) {
    rethrow;
  }
}

Future<String> _uploadImageToCloudinary(File imageFile) async {
  // Implementação do upload para o Cloudinary
  // Esta é uma implementação simplificada - você precisará ajustar
  // para usar as credenciais do Cloudinary e o endpoint correto
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/CLOUDINARY_CLOUD_NAME/image/upload');
  var request = http.MultipartRequest('POST', uri);
  
  request.fields['upload_preset'] = 'mandarImagem';
  
  final fileStream = http.ByteStream(imageFile.openRead());
  final length = await imageFile.length();
  
  final multipartFile = http.MultipartFile(
    'file',
    fileStream,
    length,
    filename: imageFile.path.split('/').last,
  );
  
  request.files.add(multipartFile);
  
  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  final jsonResponse = json.decode(responseData);
  
  return jsonResponse['secure_url'];
}

  // Atualiza o status de um imóvel
  Future<void> updatePropertyStatus(int propertyId, String newStatus) async {
    if (_authToken == null) return;
    
    final url = Uri.parse('$_baseUrl/properties/$propertyId/status');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar o status do imóvel.');
      }

      // Atualiza localmente em todas as listas para uma resposta imediata
      _updatePropertyInLists(propertyId, newStatus);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Método auxiliar para atualizar uma propriedade em todas as listas
  void _updatePropertyInLists(int propertyId, String newStatus) {
    void updateList(List<Property> list) {
      final index = list.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        list[index] = list[index].copyWith(status: newStatus);
      }
    }

    updateList(_highestPriceProperties);
    updateList(_lowestPriceProperties);
    updateList(_recentProperties);
    updateList(_filteredProperties);
    updateList(_myProperties);
  }

  // --- NOVO MÉTODO PARA EXCLUIR IMÓVEL ---
  Future<void> deleteProperty(int propertyId) async {
    if (_authToken == null) {
      throw Exception('Autenticação necessária.');
    }

    // Guarda o índice para uma possível reversão em caso de erro
    final existingPropertyIndex = _myProperties.indexWhere((prop) => prop.id == propertyId);
    Property? existingProperty = existingPropertyIndex >= 0 ? _myProperties[existingPropertyIndex] : null;
    
    // Remove o imóvel localmente para uma resposta visual imediata (atualização otimista)
    if (existingProperty != null) {
      _myProperties.removeAt(existingPropertyIndex);
      notifyListeners();
    }

    final url = Uri.parse('$_baseUrl/properties/$propertyId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      // Se a API retornar um erro, reverte a exclusão local
      if (response.statusCode >= 400) {
        if (existingProperty != null) {
          _myProperties.insert(existingPropertyIndex, existingProperty);
          notifyListeners();
        }
        throw Exception('Não foi possível excluir o imóvel.');
      }
      
      // Remove também das outras listas se existir
      _removePropertyFromAllLists(propertyId);
    } catch (error) {
      // Reverte a exclusão local em caso de qualquer erro de rede
      if (existingProperty != null) {
        _myProperties.insert(existingPropertyIndex, existingProperty);
        notifyListeners();
      }
      rethrow;
    }
  }

  // Método auxiliar para remover um imóvel de todas as listas
  void _removePropertyFromAllLists(int propertyId) {
    void removeFromList(List<Property> list) {
      list.removeWhere((p) => p.id == propertyId);
    }

    removeFromList(_highestPriceProperties);
    removeFromList(_lowestPriceProperties);
    removeFromList(_recentProperties);
    removeFromList(_filteredProperties);
    // Notifica os listeners apenas uma vez no final
    notifyListeners();
  }

  // Encontra um imóvel por ID em qualquer lista
  Property? findById(int id) {
    // Procura nas listas pela ordem de probabilidade, sem criar novas coleções
    final lists = [_myProperties, _filteredProperties, _highestPriceProperties, _lowestPriceProperties, _recentProperties];
    for (final list in lists) {
        try {
            return list.firstWhere((prop) => prop.id == id);
        } catch (e) {
            // Continua para a próxima lista se não encontrar
        }
    }
    return null; // Retorna nulo se não encontrar em nenhuma lista
  }

  // Limpa os filtros e volta para a visualização padrão
  void clearFilters() {
    _isFilteredMode = false;
    _filteredProperties = [];
    notifyListeners();
  }

}