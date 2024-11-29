import 'package:flutter/material.dart';

class ResultDisplay extends StatefulWidget {
  final String display;
  final int? currentNoteIndex; // Índice da nota atual
  final Map<String, Color> digitColors; // Mapa de cores para os dígitos
  final String operation; // Adicionado para exibir a operação

  const ResultDisplay({
    Key? key,
    required this.display,
    required this.operation,
    this.currentNoteIndex,
    required this.digitColors,
  }) : super(key: key);

  @override
  _ResultDisplayState createState() => _ResultDisplayState();
}

class _ResultDisplayState extends State<ResultDisplay> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(ResultDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Quando o currentNoteIndex mudar, rolar para o dígito correspondente
    if (widget.currentNoteIndex != null &&
        widget.currentNoteIndex != oldWidget.currentNoteIndex) {
      _scrollToCurrentDigit();
    }
  }

  void _scrollToCurrentDigit() {
    // Encontrar o índice onde começam os dígitos decimais
    int decimalStartIndex = widget.display.indexOf('.') + 1;

    // Se não houver ponto decimal, não há dígitos decimais para destacar
    if (decimalStartIndex == 0) {
      return; // Não faz nada se não houver parte decimal
    }

    // Calcular o índice real do dígito no display
    int actualIndex = decimalStartIndex + widget.currentNoteIndex!;

    // Calcular a posição de rolagem
    double offset = (actualIndex - decimalStartIndex) * 20.0; // Largura de 30px por dígito

    // Animar a rolagem para a posição calculada
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determinar altura e largura fixas para o display
    const double displayHeight = 80.0;
    const double displayWidth = double.infinity;

    // Índice inicial dos números decimais
    int decimalStartIndex = widget.display.indexOf('.') + 1;

    return Container(
      height: displayHeight, // Altura fixa do display
      width: displayWidth, // Largura total disponível
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),////////////////////////////
      decoration: BoxDecoration(
        color: Colors.blue[50], // Cor de fundo do display/////////////////////////////////
        borderRadius: BorderRadius.circular(10), // Bordas arredondadas
        border: Border.all(
          color: Colors.blue, // Borda preta
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(2, 4), // Sombra leve
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Alinha os números à direita
          children: widget.display.split('').asMap().entries.map((entry) {
            final int index = entry.key;
            final String digit = entry.value;

            // Determina se o número é decimal (após o ponto)
            bool isDecimal = decimalStartIndex > 0 && index >= decimalStartIndex;

            // Verifica se este é o dígito atual destacado
            bool isCurrentDigit =
                isDecimal && widget.currentNoteIndex != null && (index - decimalStartIndex) == widget.currentNoteIndex;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: isCurrentDigit
                    ? widget.digitColors[digit] ?? Colors.transparent
                    : Colors.transparent,
              ),
              child: Text(
                digit,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDecimal ? Colors.black : Colors.black54, // Diferenciar cor de números decimais
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
