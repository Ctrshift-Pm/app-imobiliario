import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _myProperties = [];
  final List<int> _favoritePropertyIds = [];
  final String? _authToken;
  final String _apiUrl = 'http://10.0.2.2:3333';

  PropertyProvider(this._authToken);

  List<Property> get properties => [..._properties];
  List<Property> get myProperties => [..._myProperties];
  List<Property> get favoriteProperties => _properties.where((prop) => _favoritePropertyIds.contains(prop.id)).toList();

  bool isFavorite(int propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  void toggleFavoriteStatus(int propertyId) {
    if (isFavorite(propertyId)) {
      _favoritePropertyIds.remove(propertyId);
    } else {
      _favoritePropertyIds.add(propertyId);
    }
    notifyListeners();
  }

  Future<void> fetchProperties({Map<String, String> filters = const {}}) async {
    if (_authToken == null) return;
    final uri = Uri.parse('$_apiUrl/properties').replace(queryParameters: filters);
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_authToken'},
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> propertiesData = responseData['data'];
        
        _properties = propertiesData.map((item) => Property.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar imóveis.');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchMyProperties() async {
    if (_authToken == null) return;
    final url = Uri.parse('$_apiUrl/brokers/me/properties');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $_authToken'});
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> propertiesData = responseData['data'];
        _myProperties = propertiesData.map((item) => Property.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar os seus imóveis.');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProperty(Property property) async {
    if (_authToken == null) return;
    final url = Uri.parse('$_apiUrl/properties');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'title': property.title,
          'description': property.description,
          'type': property.type,
          'purpose': property.purpose,
          'price': property.price,
          'address': property.address,
          'city': property.city,
          'state': 'GO', 
          'bedrooms': property.bedrooms,
          'bathrooms': property.bathrooms,
          'area': property.area,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao adicionar imóvel.');
      }
      // Atualiza a lista de "meus imóveis" após adicionar um novo
      await fetchMyProperties();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
  Future<void> updatePropertyStatus(int propertyId, String newStatus) async {
    if (_authToken == null) return;
    final url = Uri.parse('$_apiUrl/properties/$propertyId/status');
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

      // Atualiza o status localmente para refletir na UI imediatamente
      final propIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propIndex >= 0) {
        _properties[propIndex].status = newStatus;
      }
      final myPropIndex = _myProperties.indexWhere((p) => p.id == propertyId);
      if (myPropIndex >= 0) {
        _myProperties[myPropIndex].status = newStatus;
      }
      
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}