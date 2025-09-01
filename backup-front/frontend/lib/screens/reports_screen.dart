import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/broker_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<void> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = Provider.of<BrokerProvider>(context, listen: false).fetchMyReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _reportsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar os relatórios.'));
          } else {
            return Consumer<BrokerProvider>(
              builder: (ctx, brokerData, _) => SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Relatório de Desempenho
                    const Text('Desempenho Geral', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildKpiCard('Imóveis Vendidos', brokerData.report?.totalSales.toString() ?? '0', Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildKpiCard('Total em Comissões', 'R\$ ${brokerData.report?.totalCommission.toStringAsFixed(2) ?? '0.00'}', Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Lista de Comissões
                    const Text('Comissões Detalhadas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (brokerData.commissions.isEmpty)
                      const Text('Nenhuma comissão registada ainda.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: brokerData.commissions.length,
                        itemBuilder: (ctx, i) {
                          final commission = brokerData.commissions[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(commission.propertyTitle),
                              subtitle: Text('Venda em: ${commission.saleDate}'),
                              trailing: Text('R\$ ${commission.commissionAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ),
                          );
                        },
                      )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}