import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
import 'add_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});
  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  late Future<void> _myPropertiesFuture;

  @override
  void initState() {
    super.initState();
    _myPropertiesFuture = Provider.of<PropertyProvider>(context, listen: false).fetchMyProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddPropertyScreen.routeName);
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder(
        future: _myPropertiesFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar os seus imóveis.'));
          } else {
            return Consumer<PropertyProvider>(
              builder: (ctx, propertyProvider, _) =>
                  propertyProvider.myProperties.isEmpty
                      ? const Center(child: Text('Você ainda não cadastrou nenhum imóvel.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: propertyProvider.myProperties.length,
                          itemBuilder: (ctx, i) => PropertyCard(property: propertyProvider.myProperties[i]),
                        ),
            );
          }
        },
      ),
    );
  }
}