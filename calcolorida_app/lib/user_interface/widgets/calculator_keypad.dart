import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CalculatorKeypad({super.key, required this.onKeyPressed});

  String _getSemanticLabel(String label) {
  switch (label) {
    case 'C':
      return 'Limpar';
    case 'π':
      return 'Pi';
    case '√':
      return 'Raiz quadrada';
    case '^':
      return 'Elevado à potência';
    case '1/x':
      return 'Inverso';
    case '!':
      return 'Fatorial';
    case '<-':
      return 'Apagar dígito';
    case '/':
      return 'Divisão';
    case 'x':
      return 'Multiplicação';
    case '-':
      return 'Subtração';
    case '+':
      return 'Adição';
    case '=':
      return 'Resultado';
    case '.':
      return 'Ponto decimal';
    case 'S':
      return 'Salvar mosaico';
    default:
      return 'Número $label';
  }
}


  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 2.3,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      children: [
        _buildButton('C', color: const Color.fromARGB(219, 25, 67, 118)),
        _buildButton('π', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('√', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('^', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('1/x', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253), fontSize: 14.2),
        _buildButton('!', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('<-', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('/', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('7', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('8', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('9', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('x', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('4', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('5', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('6', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('-', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('1', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('2', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('3', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('+', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('0', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('.', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('=', color: const Color.fromARGB(255, 13, 110, 253)),
        _buildButton('S', color: const Color.fromARGB(219, 25, 67, 118)),
      ],
    );
  }

  Widget _buildButton(String label, {Color? color, Color? fontColor, double fontSize = 21.0}) {
    return Semantics(
  label: _getSemanticLabel(label),
  button: false,
  child: ElevatedButton(
    onPressed: () {
      if (label == 'S') {
        onKeyPressed('save');
      } else {
        onKeyPressed(label);
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: color ?? Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        color: fontColor ?? Colors.white,
      ),
    ),
  ),
);
  }
}
