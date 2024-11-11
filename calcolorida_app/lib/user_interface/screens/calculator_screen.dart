import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
import '../../controllers/calculator_controller.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';
import '../widgets/mosaic_display.dart';
import 'package:calcolorida_app/controllers/audio_controller.dart'; // Importar stopAudio

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _controller = CalculatorController();
  int _mosaicDecimalPlaces = 750; // Valor padrão
  int _mosaicDigitsPerRow = 19; // Valor padrão
  double _squareSize = 20.0; // Tamanho inicial dos quadrados
  final double _minSquareSize = 10.0;
  final double _maxSquareSize = 50.0;
  bool _colorLegendExpanded = false;

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
    // preloadAudio();
  }

  @override
  void dispose() {
    // disposeAudio(); // Chame a função para liberar o player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Musical Colorida'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.menu),
          //   onPressed: () {
          //     _openMenu();
          //   },
          // ),
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
                  // SizedBox(width: 4.0),
                  // Text('Cores')
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () {
      //         _controller.playMelody(); // Chamar playMelody() ao clicar em Play
      //       },
      //       child: Icon(Icons.play_arrow),
      //     ),
      //     SizedBox(width: 16),
      //     FloatingActionButton(
      //       onPressed: () {
      //         stopAudio(); // Chamar stopAudio() ao clicar em Stop
      //       },
      //       child: Icon(Icons.stop),
      //     ),
      //   ],
      // ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                // Ação para configurações
              },
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
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Sobre'),
              onTap: () {
                // Ação para sobre
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
                        style: TextStyle(
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
              ),
            ),
          ),
          // Slider para ajustar o zoom (tamanho dos quadrados)
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Row(
          //     children: [
          //       Text('Zoom:'),
          //       Expanded(
          //         child: Slider(
          //           value: _squareSize,
          //           min: _minSquareSize,
          //           max: _maxSquareSize,
          //           label: _squareSize.toStringAsFixed(1),
          //           onChanged: (double value) {
          //             setState(() {
          //               _squareSize = value;
          //             });
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Slider para dígitos por linha
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
               Text('Padrões: ${_mosaicDigitsPerRow}'), // Exibe a contagem de colunas
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _controller.playMelody();
                  },
                  child: Icon(Icons.play_arrow),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    stopAudio();
                  },
                  child: Icon(Icons.stop),
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
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: ResultDisplay(display: _controller.display),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 1),
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

  // void _openMenu() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: 200,
  //         color: Colors.grey[200],
  //         child: Center(
  //           child: Text('Menu vazio'),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _handleKeyPress(String key) {
    setState(() {
      _controller.processKey(key);
    });
  }
}
