import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final String display;

  const ResultDisplay({Key? key, required this.display}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
    color: Colors.black87,
    borderRadius: BorderRadius.circular(10.0),
  ),
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.all(9),
      child: Text(
        display,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}