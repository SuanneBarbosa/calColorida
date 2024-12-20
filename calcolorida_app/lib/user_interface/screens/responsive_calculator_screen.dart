// import 'package:flutter/material.dart';
// import 'calculator_screen.dart';

// class ResponsiveCalculatorScreen extends StatelessWidget {
//   const ResponsiveCalculatorScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth >= 800) {
//           // Para desktops
//           return const CalculatorScreen(
//             isDesktop: true,
//           );
//         } else if (constraints.maxWidth >= 600) {
//           // Para tablets
//           return const CalculatorScreen(
//             isTablet: true,
//           );
//         } else {
//           // Para celulares
//           return const CalculatorScreen(
//             isMobile: true,
//           );
//         }
//       },
//     );
//   }
// }
