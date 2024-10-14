import 'package:flutter/material.dart';

class MosaicDisplay extends StatelessWidget {
  final String result;
  final Map<String, Color> digitColors;
  final int decimalPlaces; // Novo parâmetro

  const MosaicDisplay({
    Key? key,
    required this.result,
    required this.digitColors,
    required this.decimalPlaces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildMosaic(result);
  }

  Widget _buildMosaic(String result) {
    if (result.contains('.')) {
      String decimalPart = result.split('.')[1];

      // Limitar a parte decimal ao número especificado de casas decimais
      if (decimalPart.length > decimalPlaces) {
        decimalPart = decimalPart.substring(0, decimalPlaces);
      }

      // Quebrar a parte decimal em grupos para o mosaico
      int digitsPerRow = 18; // Ajuste conforme necessário
      List<List<String>> decimalGroups = [];
      for (var i = 0; i < decimalPart.length; i += digitsPerRow) {
        int endIndex = i + digitsPerRow;
        if (endIndex > decimalPart.length) {
          endIndex = decimalPart.length;
        }
        decimalGroups.add(decimalPart.substring(i, endIndex).split(''));
      }

      // Criar as linhas do mosaico
      List<Widget> mosaicRows = decimalGroups
          .map((group) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: group
                    .map((digit) => Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: digitColors[digit],
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                        ))
                    .toList(),
              ))
          .toList();

      // Retorna um Column com as linhas do mosaico
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: mosaicRows,
      );
    } else {
      return Container();
    }
  }
}
