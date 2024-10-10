import 'package:flutter/material.dart';

class MosaicDisplay extends StatelessWidget {
  final String result;
  final Map<String, Color> digitColors;

  const MosaicDisplay({Key? key, required this.result, required this.digitColors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildMosaic(result);
  }

  Widget _buildMosaic(String result) {
    if (result.contains('.')) {
      String decimalPart = result.split('.')[1];

      // Quebrar a parte decimal em grupos de 10 dígitos
      List<List<String>> decimalGroups = [];
      for (var i = 0; i < decimalPart.length; i += 10) {
        // Extrair a substring, garantindo que não ultrapasse o final da string
        int endIndex = i + 10;
        if (endIndex > decimalPart.length) {
          endIndex = decimalPart.length;
        }
        decimalGroups.add(decimalPart.substring(i, endIndex).split(''));
      }

      // Criar uma lista de widgets para cada linha do mosaico
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