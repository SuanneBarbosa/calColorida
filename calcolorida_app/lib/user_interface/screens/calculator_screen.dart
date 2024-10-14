import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';
import '../widgets/mosaic_display.dart'; // Certifique-se de importar o MosaicDisplay

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _controller = CalculatorController();
  int _mosaicDecimalPlaces = 270; // Valor padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musical Colorida'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _openDecimalModal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[10],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(1.50),
              child: MosaicDisplay(
                result: _controller.display,
                digitColors: _controller.digitColors,
                decimalPlaces: _mosaicDecimalPlaces,
              ),
            ),
          ),
          // Adicionar o Slider aqui
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Número de casas decimais:'),
                Expanded(
                  child: Slider(
                    value: _mosaicDecimalPlaces.toDouble(),
                    min: 1,
                    max: 270,
                    divisions: 20,
                    label: _mosaicDecimalPlaces.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _mosaicDecimalPlaces = value.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Card(
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
                      padding: EdgeInsets.all(12),
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

  // Função que abre o modal (pode ser mantida ou removida conforme necessário)
  void _openDecimalModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Escolha o número de casas decimais para o resultado:'),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Casas decimais',
                ),
                onChanged: (value) {
                  int decimalPlaces = int.tryParse(value) ?? 2;
                  setState(() {
                    _controller.setDecimalPlaces(decimalPlaces);
                    // Atualiza o mosaico se necessário
                    if (_mosaicDecimalPlaces > decimalPlaces) {
                      _mosaicDecimalPlaces = decimalPlaces;
                    }
                  });
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

  // Função para lidar com teclas pressionadas
  void _handleKeyPress(String key) {
    setState(() {
      _controller.processKey(key);
    });
  }
}
