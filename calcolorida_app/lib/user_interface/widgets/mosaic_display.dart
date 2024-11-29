import 'package:flutter/material.dart';

class MosaicDisplay extends StatefulWidget {
  final String result;
  final Map<String, Color> digitColors;
  final int decimalPlaces;
  final int digitsPerRow;
  final double squareSize;
  final int? currentNoteIndex; // Índice da nota atual
  final Function(int)? onNoteTap;
  final Function(int)?
      onMaxDigitsCalculated; // Callback para informar o maxDigits

  const MosaicDisplay({
    Key? key,
    required this.result,
    required this.digitColors,
    required this.decimalPlaces,
    required this.digitsPerRow,
    required this.squareSize,
    this.currentNoteIndex,
    this.onNoteTap,
    this.onMaxDigitsCalculated, // Inicialização do callback
  }) : super(key: key);

  @override
  _MosaicDisplayState createState() => _MosaicDisplayState();
}

class _MosaicDisplayState extends State<MosaicDisplay> {
  int? _previousMaxDigits;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;

        // Número fixo de linhas que queremos manter
        int numRows = 14;

        // Calcula quantos quadrados (em altura) cabem na área disponível
        int maxRows = (availableHeight / widget.squareSize).floor();

        // Ajusta o número de linhas se necessário para não exceder a altura disponível
        if (maxRows < numRows) {
          numRows = maxRows;
        }

        // Obter o número de dígitos por linha
        int digitsPerRow = widget.digitsPerRow;

        // Calcular o número máximo de dígitos (quadrados) no mosaico
        int maxDigits = digitsPerRow * numRows;

        // Se o maxDigits mudou, agendar um callback para notificar o widget pai
        if (_previousMaxDigits != maxDigits) {
          _previousMaxDigits = maxDigits;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.onMaxDigitsCalculated != null) {
              widget.onMaxDigitsCalculated!(maxDigits);
            }
          });
        }

        return _buildMosaic(widget.result, maxDigits, digitsPerRow);
      },
    );
  }

  Widget _buildMosaic(String result, int maxDigits, int digitsPerRow) {
    if (result.contains('.')) {
      String decimalPart = result.split('.')[1];

      // Remover zeros à direita
      decimalPart = decimalPart.replaceAll(RegExp(r'0+$'), '');

      // Limitar a parte decimal ao número máximo de dígitos que cabem no mosaico
      if (decimalPart.length > maxDigits) {
        decimalPart = decimalPart.substring(0, maxDigits);
      }

      // Quebrar a parte decimal em grupos para o mosaico
      List<List<String>> decimalGroups = [];
      for (var i = 0; i < decimalPart.length; i += digitsPerRow) {
        int endIndex = i + digitsPerRow;
        if (endIndex > decimalPart.length) {
          endIndex = decimalPart.length;
        }
        decimalGroups.add(decimalPart.substring(i, endIndex).split(''));
      }

      // Criar as linhas do mosaico
      List<Widget> mosaicRows = decimalGroups.asMap().entries.map((entry) {
        final int rowIndex = entry.key;
        final List<String> group = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              MainAxisAlignment.start, // Alinha os quadrados à esquerda
          children: group.asMap().entries.map((entry) {
            final int digitIndex = entry.key;
            final String digit = entry.value;
            final int globalIndex = rowIndex * digitsPerRow + digitIndex;

            return GestureDetector(
              onTap: () {
                if (widget.onNoteTap != null) {
                  widget.onNoteTap!(globalIndex);
                }
              },
              child: Container(
                width: widget.squareSize,
                height: widget.squareSize,
                decoration: BoxDecoration(
                  color: widget.currentNoteIndex == globalIndex
                      ? Colors.black // Destaca o quadrado da nota atual
                      : widget.digitColors[digit], // Cor do dígito
                  border: Border.all(color: Colors.black, width: 1),
                ),
              ),
            );
          }).toList(),
        );
      }).toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: mosaicRows,
        ),
      );
    } else {
      return Container();
    }
  }
}
