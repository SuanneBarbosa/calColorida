// models/mosaic_data.dart
import 'package:flutter/material.dart';

class MosaicData {
  final String operation;
  final String result;
  final int digitsPerRow;
  final double squareSize;

  MosaicData({
    required this.operation,
    required this.result,
    required this.digitsPerRow,
    required this.squareSize,
  });


  Map<String, dynamic> toJson() => {
        'operation': operation,
        'result': result,
        'digitsPerRow': digitsPerRow,
        'squareSize': squareSize,
      };

  factory MosaicData.fromJson(Map<String, dynamic> json) => MosaicData(
        operation: json['operation'],
        result: json['result'],
        digitsPerRow: json['digitsPerRow'],
        squareSize: json['squareSize'],
      );

}