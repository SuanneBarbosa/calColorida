import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CalculatorKeypad({Key? key, required this.onKeyPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 2, // Reduzido para 1.0 para botões menores
      mainAxisSpacing: 4,  // Espaçamento vertical entre as linhas
      crossAxisSpacing: 4,
      children: [
        _buildButton('C', color: Colors.red),
        _buildButton('π', color: Colors.white, fontColor: Colors.orange),
        _buildButton('√', color: Colors.white, fontColor: Colors.orange),
        _buildButton('^', color: Colors.white, fontColor: Colors.orange),
        _buildButton('1/x', color: Colors.white, fontColor: Colors.orange),
        _buildButton('!', color: Colors.white, fontColor: Colors.orange),
        _buildButton('<-', color: Colors.white, fontColor: Colors.orange),
        _buildButton('/', color: Colors.white, fontColor: Colors.orange),
        _buildButton('7'),
        _buildButton('8'),
        _buildButton('9'),
        _buildButton('x', color: Colors.white, fontColor: Colors.orange),
        _buildButton('4'),
        _buildButton('5'),
        _buildButton('6'),
        _buildButton('-', color: Colors.white, fontColor: Colors.orange),
        _buildButton('1'),
        _buildButton('2'),
        _buildButton('3'),
        _buildButton('+', color: Colors.white, fontColor: Colors.orange),
        _buildButton('0'),
        _buildButton('.'),
        _buildButton('=', color: Colors.orange),
        _buildButton('S', color: Colors.orange),
      ],
    );
  }

 Widget _buildButton(String label, {Color? color, Color? fontColor}) {
    return ElevatedButton(
      child: Text(
        label,
        style: TextStyle(fontSize: 20, color: fontColor ?? Colors.white),
      ),
      onPressed: () => onKeyPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ??Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}