// [user_interface\screens\responsive_calculator_screen.dart]

import 'package:flutter/material.dart';
import 'calculator_screen.dart';

class ResponsiveCalculatorScreen extends StatelessWidget {
  const ResponsiveCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Definir breakpoints
        if (constraints.maxWidth >= 1200) {
          // Desktop
          return const CalculatorScreenLayout(
            layoutType: LayoutType.desktop,
          );
        } else if (constraints.maxWidth >= 800) {
          // Tablet
          return const CalculatorScreenLayout(
            layoutType: LayoutType.tablet,
          );
        } else {
          // Mobile
          return const CalculatorScreenLayout(
            layoutType: LayoutType.mobile,
          );
        }
      },
    );
  }
}

// Definir tipos de layout
enum LayoutType { mobile, tablet, desktop }

// Criar uma versão adaptável da CalculatorScreen
class CalculatorScreenLayout extends StatelessWidget {
  final LayoutType layoutType;

  const CalculatorScreenLayout({Key? key, required this.layoutType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (layoutType) {
      case LayoutType.desktop:
        return _buildDesktopLayout(context);
      case LayoutType.tablet:
        return _buildTabletLayout(context);
      case LayoutType.mobile:
      default:
        return const CalculatorScreen(); // Já existente para mobile
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Colorida - Desktop'),
      ),
      drawer: const Drawer(), // Você pode adaptar o Drawer para desktop
      body: Row(
        children: [
          // Sidebar ou Menu para desktop
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calculate),
                label: Text('Calculadora'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('Mosaicos Salvos'),
              ),
              // Adicione mais destinos conforme necessário
            ],
            selectedIndex: 0,
          ),
          // Conteúdo principal
          const VerticalDivider(thickness: 1, width: 1),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CalculatorScreen(), // Sua tela existente
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Colorida - Tablet'),
      ),
      drawer: const Drawer(), // Você pode adaptar o Drawer para tablet
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CalculatorScreen(), // Sua tela existente
      ),
    );
  }
}
