import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CalculatorKeypad({Key? key, required this.onKeyPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 2.3, 
      mainAxisSpacing: 4,  
      crossAxisSpacing: 4,
      children: [
        _buildButton('C', color: const Color.fromARGB(219, 25, 67, 118)),
        _buildButton('π', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('√', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('^', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('1/x', color: Colors.white, fontColor:const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('!', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('<-', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('/', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('7'),
        _buildButton('8'),
        _buildButton('9'),
        _buildButton('x', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('4'),
        _buildButton('5'),
        _buildButton('6'),
        _buildButton('-', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('1'),
        _buildButton('2'),
        _buildButton('3'),
        _buildButton('+', color: Colors.white, fontColor: const Color.fromARGB(219, 13, 110, 253)),
        _buildButton('0'),
        _buildButton('.'),
        _buildButton('=', color: const Color.fromARGB(219, 25, 67, 118)),
        _buildButton('S', color: const Color.fromARGB(219, 25, 67, 118)),
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