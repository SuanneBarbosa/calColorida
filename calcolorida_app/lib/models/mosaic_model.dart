
// ignore: unused_import
import 'dart:convert';

class MosaicModel {
  final String operation;
  final String result;
  final double squareSize;
  final String instrument;
  final int noteDurationMs;

  MosaicModel({
    required this.operation,
    required this.result,
    required this.squareSize,
    required this.instrument,
    required this.noteDurationMs,
  });

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'result': result,
        'squareSize': squareSize,
        'instrument': instrument,
        'noteDurationMs': noteDurationMs,
      };

  factory MosaicModel.fromJson(Map<String, dynamic> json) => MosaicModel(
        operation: json['operation'],
        result: json['result'],
        squareSize: json['squareSize'],
        instrument: json['instrument'],
        noteDurationMs: json['noteDurationMs'],
      );
}