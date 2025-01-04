
// ignore: unused_import
import 'dart:convert';

class MosaicModel {
  final String operation;
  final String result;
  final double squareSize;
  final String instrument;
  final int noteDurationMs;
  final int mosaicDigitsPerRow;
  final bool isFixed; // Novo campo para diferenciar mosaicos fixos

  MosaicModel({
    required this.operation,
    required this.result,
    required this.squareSize,
    required this.instrument,
    required this.noteDurationMs,
    required this.mosaicDigitsPerRow,
     this.isFixed = false, // Padrão: mosaico não é fixo
  });

  Map<String, dynamic> toJson() => {
        'operation': operation,
        'result': result,
        'squareSize': squareSize,
        'instrument': instrument,
        'noteDurationMs': noteDurationMs,
        'mosaicDigitsPerRow': mosaicDigitsPerRow,
        'isFixed': isFixed, // Inclui a propriedade no JSON
      };

  factory MosaicModel.fromJson(Map<String, dynamic> json) => MosaicModel(
        operation: json['operation'],
        result: json['result'],
        squareSize: json['squareSize'],
        instrument: json['instrument'],
        noteDurationMs: json['noteDurationMs'],
        mosaicDigitsPerRow: json['mosaicDigitsPerRow'],
        isFixed: json['isFixed'] ?? false, // Valor padrão ao carregar
      );
}