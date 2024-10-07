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
    if (result.contains('.')) { // Verifica se result contém ponto decimal
      // Extrair a parte decimal do resultado
      String decimalPart = result.split('.')[1];

      // Criar uma lista de widgets para cada quadrado do mosaico
      List<Widget> mosaicTiles = decimalPart
          .split('')
          .map((digit) => Container(
            width: 20, // Ajustar o tamanho do quadrado
            height: 20, // Ajustar o tamanho do quadrado
            decoration: BoxDecoration(
              color: digitColors[digit], // Obter a cor do mapa
              border: Border.all(color: Colors.black, width: 1), // Adicione borda ao quadrado
            ),
          ))
          .toList();

      // Retornar um Row com os quadrados do mosaico
      return Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centralizar os quadrados
        children: mosaicTiles,
      );
    } else {
      // Retorna um Container vazio se a parte decimal for vazia
      return Container();
    }
  }
}