
// ignore: unused_import
import 'dart:convert';

class MosaicModel {
  final String operation;
  final String result;
  final double squareSize;
  final String instrument;
  final int noteDurationMs;
  final int mosaicDigitsPerRow;

  MosaicModel({
    required this.operation,
    required this.result,
    required this.squareSize,
    required this.instrument,
    required this.noteDurationMs,
    required this.mosaicDigitsPerRow,
  });

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'result': result,
        'squareSize': squareSize,
        'instrument': instrument,
        'noteDurationMs': noteDurationMs,
        'mosaicDigitsPerRow': mosaicDigitsPerRow,
      };

  factory MosaicModel.fromJson(Map<String, dynamic> json) => MosaicModel(
        operation: json['operation'],
        result: json['result'],
        squareSize: json['squareSize'],
        instrument: json['instrument'],
        noteDurationMs: json['noteDurationMs'],
        mosaicDigitsPerRow: json['mosaicDigitsPerRow'],
      );
}