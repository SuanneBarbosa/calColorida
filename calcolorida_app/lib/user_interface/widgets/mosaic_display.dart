import 'package:flutter/material.dart';

class MosaicDisplay extends StatefulWidget {
  final String result;
  final Map<String, Color> digitColors;
  final int decimalPlaces;
  final int digitsPerRow;
  final double squareSize;

  const MosaicDisplay({
    Key? key,
    required this.result,
    required this.digitColors,
    required this.decimalPlaces,
    required this.digitsPerRow,
    required this.squareSize,
  }) : super(key: key);

  @override
  _MosaicDisplayState createState() => _MosaicDisplayState();
}

class _MosaicDisplayState extends State<MosaicDisplay> {
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

        // Calcula o número total de dígitos que cabem no mosaico
        int maxDigits = widget.digitsPerRow * numRows;

        return _buildMosaic(widget.result, maxDigits, numRows);
      },
    );
  }

  Widget _buildMosaic(String result, int maxDigits, int numRows) {
    if (result.contains('.')) {
      String decimalPart = result.split('.')[1];

      // Limitar a parte decimal ao número máximo de dígitos que cabem no mosaico
      if (decimalPart.length > maxDigits) {
        decimalPart = decimalPart.substring(0, maxDigits);
      }

      // Quebrar a parte decimal em grupos para o mosaico
      List<List<String>> decimalGroups = [];
      for (var i = 0; i < decimalPart.length; i += widget.digitsPerRow) {
        int endIndex = i + widget.digitsPerRow;
        if (endIndex > decimalPart.length) {
          endIndex = decimalPart.length;
        }
        decimalGroups.add(decimalPart.substring(i, endIndex).split(''));
      }

      // Criar as linhas do mosaico
      List<Widget> mosaicRows = decimalGroups
          .map((group) =>
              Row(
                mainAxisSize: MainAxisSize.min,
                children: group
                    .map((digit) => Container(
                          width: widget.squareSize,
                          height: widget.squareSize,
                          decoration: BoxDecoration(
                            color: widget.digitColors[digit],
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                        ))
                    .toList(),
              ))
          .toList();

      // Garantir que não excedamos o número de linhas calculado
      if (mosaicRows.length > numRows) {
        mosaicRows = mosaicRows.sublist(0, numRows);
      }

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
