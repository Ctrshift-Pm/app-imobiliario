import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart'; // Importar para limpar os filtros
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'my_properties_screen.dart';
import 'profile_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages = [];
  int _selectedPageIndex = 0;

  // Chave global para aceder ao estado do HomeScreen
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final userRole = Provider.of<AuthProvider>(context, listen: false).user?.role;

    // Constrói a lista de páginas, associando a chave ao HomeScreen
    _pages = [
      {'page': HomeScreen(key: _homeScreenKey), 'title': 'Início'},
      if (userRole == 'user') {'page': const FavoritesScreen(), 'title': 'Favoritos'},
      if (userRole == 'broker') {'page': const MyPropertiesScreen(), 'title': 'Meus Imóveis'},
      {'page': const ProfileScreen(), 'title': 'Perfil'},
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final userRole = authProvider.user?.role;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title'] as String),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Mostra os botões de filtro apenas no ecrã principal (índice 0)
          if (_selectedPageIndex == 0) ...[
            if (propertyProvider.isFilteredMode)
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  // Limpa os filtros através do provider
                  propertyProvider.clearFilters();
                },
                tooltip: 'Limpar Filtros',
              ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Chama o método openFilterSheet do HomeScreen através da GlobalKey
                _homeScreenKey.currentState?.openFilterSheet();
              },
              tooltip: 'Filtrar',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Adicionar navegação para o ecrã de login, se necessário
            },
          ),
        ],
      ),
      body: _pages[_selectedPageIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).primaryColor,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          if (userRole == 'user')
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
          if (userRole == 'broker')
            const BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'Meus Imóveis',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

