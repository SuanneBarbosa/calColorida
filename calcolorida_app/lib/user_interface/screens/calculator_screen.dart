import 'package:calcolorida_app/controllers/audio_controller.dart';
import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../screens/saved_mosaics_screen.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';
import '../widgets/mosaic_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _controller = CalculatorController();
  int _mosaicDecimalPlaces = 400;
  int _mosaicDigitsPerRow = 19;
  double _squareSize = 20.0;
  final double _minSquareSize = 10.0;
  final double _maxSquareSize = 50.0;
  bool _colorLegendExpanded = false;
  int _noteDurationMs = 500;
  int? _currentNoteIndex; // Índice da nota atual sendo tocada
  bool _isPlaying = false; // Indica se está tocando ou não
  int _maxDigitsInMosaic = 0; // Adicione esta variável

  final Map<String, Color> digitColors = {
    '0': Colors.red,
    '1': Colors.green,
    '2': Colors.blue,
    '3': Colors.yellow,
    '4': Colors.purple,
    '5': Colors.orange,
    '6': Colors.pink,
    '7': Colors.brown,
    '8': Colors.grey,
    '9': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    initializeAudio();
  }

  @override
  void dispose() {
    disposeAudio(); // Adicione esta linha para liberar o player de áudio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _colorLegendExpanded = !_colorLegendExpanded;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(
                    _colorLegendExpanded
                        ? Icons.palette
                        : Icons.palette_outlined,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'MusicalColorida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              // leading: Icon(Icons.settings),
              title: Text('Menu'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.zoom_in),
              title: Text('Zoom do Mosaico'),
              subtitle: Slider(
                value: _squareSize,
                min: _minSquareSize,
                max: _maxSquareSize,
                label: _squareSize.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    _squareSize = value;
                  });
                },
              ),
            ),
            // Controle de Velocidade no Menu Lateral
            ListTile(
              leading: Icon(Icons.speed),
              title: Text('Velocidade de Reprodução'),
              subtitle: Slider(
                value: (3000 - _noteDurationMs).toDouble(),
                min: 0,
                max: 2900,
                divisions: 29,
                onChanged: (value) {
                  setState(() {
                    _noteDurationMs = 3000 - value.toInt();
                  });
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Mosaicos Salvos'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SavedMosaicsScreen(controller: _controller),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_colorLegendExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: digitColors.entries.map((entry) {
                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
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
                digitsPerRow: _mosaicDigitsPerRow,
                squareSize: _squareSize,
                currentNoteIndex: _currentNoteIndex, // Passe o índice atual
                onMaxDigitsCalculated: (maxDigits) {
                  setState(() {
                    _maxDigitsInMosaic = maxDigits;
                  });
                },
                onNoteTap: (index) {
                  // Callback para toque na nota
                  // Lógica para reproduzir a nota individual
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${_mosaicDigitsPerRow}', // Exibe a contagem de colunas
                  style: TextStyle(
                    color: Colors.blue, // Define a cor do texto
                    fontWeight: FontWeight.bold, // Torna o texto em negrito
                    fontSize: 30, // Ajusta o tamanho do texto
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _mosaicDigitsPerRow.toDouble(),
                    min: 1,
                    max: 40,
                    label: _mosaicDigitsPerRow.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _mosaicDigitsPerRow = value.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Área para controles de áudio
          // Padding(
          //   // padding:
          //   //     const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (_isPlaying) {
                      // Parar a reprodução
                      _controller.stopMelody();
                      _isPlaying = false; // Atualiza para "Stop"
                    } else {
                      // Iniciar a reprodução
                      _controller.playMelody(
                        durationMs: _noteDurationMs,
                        maxDigits: _maxDigitsInMosaic,
                        onNoteStarted: (noteIndex) {
                          setState(() {
                            _currentNoteIndex =
                                noteIndex; // Atualiza o índice da nota atual
                          });
                        },
                        onNoteFinished: (noteIndex) {
                          setState(() {
                            _currentNoteIndex =
                                null; // Reseta o índice após a reprodução
                            _isPlaying =
                                false; // Reseta para "Play" quando terminar
                          });
                        },
                      );
                      _isPlaying = true; // Atualiza para "Play"
                    }
                  });
                },
                child: Icon(
                  _isPlaying
                      ? Icons.stop
                      : Icons.play_arrow, // Muda o ícone dinamicamente
                  color: _isPlaying
                      ? Color.fromARGB(255, 84, 173, 255) // Cor do ícone "Stop"
                      : Color.fromARGB(
                          255, 13, 110, 253), // Cor do ícone "Play"
                ),
              ),
            ],
          ),
          Expanded(
            flex: 4,
            child: Card(
              margin: EdgeInsets.all(30),
              color: Color.fromARGB(255, 84, 173, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: ResultDisplay(
                        display: _controller.display,
                        operation:
                            _controller.expression, // Passe a operação atual
                        currentNoteIndex: _currentNoteIndex,
                        digitColors: _controller.digitColors,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 4, 15, 1),
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

  void _handleKeyPress(String key) {
    setState(() {
      _controller.processKey(key);
      _currentNoteIndex = -1; // Reseta o índice ao pressionar uma tecla
    });
  }
}
