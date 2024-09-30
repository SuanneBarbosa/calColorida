import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _controller = CalculatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musical Colorida'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3, 
            child: Text(""), // Espaço vazio para futuras funcionalidades
          ),
          Expanded( // Envolve o display e keypad com Expanded
            flex: 4,  // Ajuste o flex conforme necessário
            child: Card( // Adiciona o Card aqui
              margin: EdgeInsets.all(20),
              color: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: ResultDisplay(display: _controller.display),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: CalculatorKeypad(onKeyPressed: _handleKeyPress),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleKeyPress(String key) {
    setState(() {
      _controller.processKey(key);
    });
  }
}