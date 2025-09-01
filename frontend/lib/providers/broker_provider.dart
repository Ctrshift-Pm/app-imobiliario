import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Commission {
  final int id;
  final String propertyTitle;
  final String saleDate;
  final double commissionAmount;
  Commission({required this.id, required this.propertyTitle, required this.saleDate, required this.commissionAmount});
}

class PerformanceReport {
  final int totalSales;
  final double totalCommission;
  final int totalProperties;
  PerformanceReport({required this.totalSales, required this.totalCommission, required this.totalProperties});
}

class BrokerProvider with ChangeNotifier {
  final String? _authToken;
  final String _apiUrl = 'http://10.0.2.2:3333';

  List<Commission> _commissions = [];
  PerformanceReport? _report;

  BrokerProvider(this._authToken);

  List<Commission> get commissions => [..._commissions];
  PerformanceReport? get report => _report;

  Future<void> fetchMyReports() async {
    if (_authToken == null) return;
    
    // Busca os dois endpoints em paralelo
    try {
      final commissionFuture = http.get(
        Uri.parse('$_apiUrl/brokers/me/commissions'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );
      final performanceFuture = http.get(
        Uri.parse('$_apiUrl/brokers/me/performance'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      final responses = await Future.wait([commissionFuture, performanceFuture]);

      // Processa a resposta das comissões
      if (responses[0].statusCode == 200) {
        final List<dynamic> commissionsData = json.decode(responses[0].body);
        _commissions = commissionsData.map((item) => Commission(
          id: item['id'],
          propertyTitle: item['title'],
          saleDate: item['sale_date'],
          commissionAmount: double.parse(item['commission_amount'].toString()),
        )).toList();
      }

      // Processa a resposta do relatório de desempenho
      if (responses[1].statusCode == 200) {
        final reportData = json.decode(responses[1].body);
        _report = PerformanceReport(
          totalSales: reportData['totalSales'],
          totalCommission: double.parse(reportData['totalCommission'].toString()),
          totalProperties: reportData['totalProperties'],
        );
      }
      
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
