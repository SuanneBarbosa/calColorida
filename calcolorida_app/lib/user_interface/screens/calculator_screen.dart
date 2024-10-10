import 'package:calcolorida_app/user_interface/widgets/mosaic_display.dart';
import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';
// import 'package:decimal/decimal.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _controller = CalculatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musical Colorida'),
        actions: [ // Adiciona o ícone de ferramenta na AppBar
          IconButton(
            icon: Icon(Icons.settings),  // Ícone de ferramenta
            onPressed: () {
              _openDecimalModal();  // Chama a função para abrir o modal
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3, // Ajuste o tamanho do display conforme necessário
            child: Container( // Adiciona um Container aqui
              decoration: BoxDecoration(
                color: Colors.yellow[10], // Define a cor do fundo
                borderRadius: BorderRadius.circular(20), // Define o raio do arredondamento
                // border: Border.all(color: Colors.black, width: 2), // Adiciona uma borda
              ),
              padding: const EdgeInsets.all(1.50), // Ajuste o padding conforme necessário
              child: MosaicDisplay(result: _controller.display, digitColors: _controller.digitColors),
            ),
          ),
          Expanded( // Envolve o display e keypad com Expanded
            flex: 4,  // Ajuste o flex conforme necessário
            child: Card( // Adiciona o Card aqui
              margin: EdgeInsets.all(20),
              color: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: ResultDisplay(display: _controller.display),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: CalculatorKeypad(onKeyPressed: _handleKeyPress),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função que abre o modal
  void _openDecimalModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Definir Casas Decimais'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Escolha o número de casas decimais para o resultado:'),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Casas decimais',
                ),
                onChanged: (value) { ////////////////////Diferença
                  _controller.setDecimalPlaces(int.tryParse(value) ?? 2);  // Define o número de casas decimais
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Definir'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleKeyPress(String key) {
    setState(() {
      _controller.processKey(key);
    });
  }

}