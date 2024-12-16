import 'dart:math';
import 'package:calcolorida_app/controllers/audio_controller.dart';
import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../../services/shared_preferences_service.dart';
import '../screens/saved_mosaics_screen.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';
import '../widgets/mosaic_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late CalculatorController _controller;
  final int _mosaicDecimalPlaces = 400;
  int _mosaicDigitsPerRow = 19;
  double _squareSize = 20.0;
  final double _minSquareSize = 10.0;
  final double _maxSquareSize = 50.0;
  bool _colorLegendExpanded = false;
  int _noteDurationMs = 500;
  int? _currentNoteIndex;
  bool _isPlaying = false;
  int _maxDigitsInMosaic = 0;
  // ignore: unused_field
  bool _showChallengeMosaic = false;
  String _challengeMosaic = "";
  String? _activeChallengeType;
  bool _isPlayingAudio = false;

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
    _controller = CalculatorController();
    // _loadPreferences();
    _controller.loadMosaics();
    // initializeAudio();

  }

  @override
  void dispose() {
    disposeAudio();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    await _controller.loadSettings();

    final zoom = await SharedPreferencesService.getZoom();
    final savedInstrument = await SharedPreferencesService.getInstrument();
    final result = await SharedPreferencesService.getResult();
    final operation = await SharedPreferencesService.getOperation();
    final duration = await SharedPreferencesService.getNoteDuration();

    setState(() {
      _squareSize = zoom ?? 20.0;

      if (savedInstrument != null) {
        selectedInstrument = savedInstrument;
      } else {
        selectedInstrument = 'piano';
      }

      if (result != null && operation != null) {
        _controller.loadMosaic(operation, result);
      }

      if (duration != null) {
        _noteDurationMs = duration;
      }
    });
  }

  void _showChallengesModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            runSpacing: 10,
            children: [
              const Text(
                "Escolha um Desafio",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Desafio Padrão
                  _startStandardChallenge();
                },
                child: const Text("Padrão (Apenas Mosaico)"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Desafio Som
                  print("Desafio Som selecionado");
                  _startSoundChallenge();
                },
                child: const Text("Som (Apenas Áudio)"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Desafio Som e Imagem
                  print("Desafio Som e Imagem selecionado");
                  _startSoundAndImageChallenge();
                },
                child: const Text("Som e Imagem"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateChallengeMosaic() {
    final rand = Random();
    const length = 247; // Quantidade de dígitos no total
    String randomMosaic = "";

    // Decide aleatoriamente se o número será periódico ou não periódico
    bool isPeriodic = rand.nextBool();

    if (isPeriodic) {
      // Criar sequência periódica
      int periodLength =
          rand.nextInt(5) + 1; // Tamanho do período (1 a 5 dígitos)
      String period = "";
      for (int i = 0; i < periodLength; i++) {
        period += rand.nextInt(10).toString();
      }

      // Repetir o período até atingir o comprimento necessário
      while (randomMosaic.length < length) {
        randomMosaic += period;
      }
      randomMosaic =
          randomMosaic.substring(0, length); // Ajustar para o comprimento exato
    } else {
      // Criar número não periódico
      for (int i = 0; i < length; i++) {
        randomMosaic += rand.nextInt(10).toString();
      }
    }

    _challengeMosaic = "0.$randomMosaic";
  }

  void _toggleAudioPlayback() {
    if (_isPlayingAudio) {
      // Pausa o áudio
      player?.pause();
      setState(() {
        _isPlayingAudio = false;
      });
    } else {
      // Reproduz ou reinicia o áudio
      player?.play();
      setState(() {
        _isPlayingAudio = true;
      });
    }
  }

  void _repeatAudio() {
    String decimalPart = _challengeMosaic.split('.')[1];
    List<int> digits = decimalPart.split('').map(int.parse).toList();

    // Reproduz o som novamente
    playMelodyAudio(
      digits: digits,
      durationMs: 500,
      onNoteStarted: (noteIndex) {},
      onNoteFinished: (noteIndex) {},
      onPlaybackCompleted: () {
        setState(() {
          _isPlayingAudio = false; // Altera o botão para "Reproduzir"
        });
      },
    );

    setState(() {
      _isPlayingAudio = true; // Atualiza o estado para "tocando"
    });
  }

  void _startStandardChallenge() {
    _controller.processKey('C'); // Limpa a tela antes de iniciar o desafio
    _generateChallengeMosaic(); // Gera o número decimal (periódico ou não periódico)

    setState(() {
      _activeChallengeType = 'standard'; // Tipo de desafio
    });
  }

  void _startSoundAndImageChallenge() {
    _controller.processKey('C'); // Limpa a tela antes de iniciar o desafio
    _generateChallengeMosaic(); // Gera o número decimal (periódico ou não periódico)

    setState(() {
      _activeChallengeType = 'soundAndImage';
      _isPlayingAudio = true; // O som começa tocando
    });

    // Extrair dígitos e reproduzir som
    String decimalPart = _challengeMosaic.split('.')[1];
    List<int> digits = decimalPart.split('').map(int.parse).toList();

    playMelodyAudio(
      digits: digits,
      durationMs: 500,
      onNoteStarted: (noteIndex) {},
      onNoteFinished: (noteIndex) {},
      onPlaybackCompleted: () {
        setState(() {
          _isPlayingAudio =
              false; // Altera o botão para "Reproduzir" ao terminar
        });
      },
    );
  }

  void _startSoundChallenge() {
    _controller.processKey('C'); // Limpa a tela antes de iniciar o desafio
    _generateChallengeMosaic();

    setState(() {
      _activeChallengeType = 'sound';
      _isPlayingAudio = true; // Começa no estado "tocando"
    });

    String decimalPart = _challengeMosaic.split('.')[1];
    List<int> digits = decimalPart.split('').map(int.parse).toList();

    playMelodyAudio(
      digits: digits,
      durationMs: 500,
      onPlaybackCompleted: () {
        setState(() {
          _isPlayingAudio = false; // Define como "não tocando" ao finalizar
        });
      },
    );
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
              margin: const EdgeInsets.only(right: 16.0),
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
              title: const Text('Menu'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('Zoom do Mosaico'),
              subtitle: Slider(
                value: _squareSize,
                min: _minSquareSize,
                max: _maxSquareSize,
                label: _squareSize.toStringAsFixed(1),
                onChanged: (double value) async {
                  setState(() {
                    _squareSize = value;
                  });
                  await SharedPreferencesService.saveZoom(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Velocidade de Reprodução'),
              subtitle: Slider(
                value: (3000 - _noteDurationMs).toDouble(),
                min: 0,
                max: 2900,
                divisions: 29,
                onChanged: (value) async {
                  setState(() {
                    _noteDurationMs = 3000 - value.toInt();
                  });
                  await SharedPreferencesService.saveNoteDuration(
                      _noteDurationMs);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Mosaicos Salvos'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SavedMosaicsScreen(
                      controller: _controller,
                      onMosaicApplied: () async {
                        final zoom = await SharedPreferencesService.getZoom();
                        final instrument =
                            await SharedPreferencesService.getInstrument();
                        final duration =
                            await SharedPreferencesService.getNoteDuration();

                        setState(() {
                          if (zoom != null) {
                            _squareSize = zoom;
                          }

                          if (instrument != null) {
                            selectedInstrument = instrument;
                            initializeAudio();
                          }
                          if (duration != null) {
                            _noteDurationMs = duration;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Desafios'),
              onTap: () {
                Navigator.pop(context);
                _showChallengesModal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Instrumento'),
              subtitle: DropdownButton<String>(
                value: selectedInstrument,
                items: instrumentFileNameMap.keys
                    .map<DropdownMenuItem<String>>((String instrument) {
                  return DropdownMenuItem<String>(
                    value: instrument,
                    child: Text(instrument),
                  );
                }).toList(),
                onChanged: (String? newInstrument) async {
                  if (newInstrument != null) {
                    setState(() {
                      selectedInstrument = newInstrument;
                      initializeAudio();
                    });
                    await SharedPreferencesService.saveInstrument(
                        newInstrument);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_colorLegendExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                    currentNoteIndex: _currentNoteIndex,
                    onMaxDigitsCalculated: (maxDigits) {
                      setState(() {
                        _maxDigitsInMosaic = maxDigits;
                      });
                    },
                    onNoteTap: (index) {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '$_mosaicDigitsPerRow',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (_isPlaying) {
                          _controller.stopMelody();
                          _isPlaying = false;
                        } else {
                          _controller.playMelody(
                            durationMs: _noteDurationMs,
                            maxDigits: _maxDigitsInMosaic,
                            onNoteStarted: (noteIndex) {
                              setState(() {
                                _currentNoteIndex = noteIndex;
                              });
                            },
                            onNoteFinished: (noteIndex) {
                              setState(() {
                                _currentNoteIndex = null;
                                _isPlaying = false;
                              });
                            },
                          );
                          _isPlaying = true;
                        }
                      });
                    },
                    child: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      color: _isPlaying
                          ? const Color.fromARGB(255, 84, 173, 255)
                          : const Color.fromARGB(255, 13, 110, 253),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: 4,
                child: Card(
                  margin: const EdgeInsets.all(30),
                  color: const Color.fromARGB(255, 84, 173, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                          child: ResultDisplay(
                            display: _controller.display,
                            operation: _controller.expression,
                            currentNoteIndex: _currentNoteIndex,
                            digitColors: _controller.digitColors,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 4, 15, 1),
                          child:
                              CalculatorKeypad(onKeyPressed: _handleKeyPress),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_activeChallengeType == 'standard')
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Desafio Padrão",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      MosaicDisplay(
                        result: _challengeMosaic,
                        digitColors: digitColors,
                        decimalPlaces: 400,
                        digitsPerRow: 19,
                        squareSize: 15.0,
                        currentNoteIndex: null,
                        onNoteTap: null,
                        onMaxDigitsCalculated: null,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text("Fechar"),
                            onPressed: () {
                              setState(() {
                                _activeChallengeType = null;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          if (_activeChallengeType == 'soundAndImage')
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Desafio Som e Imagem",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      MosaicDisplay(
                        result: _challengeMosaic,
                        digitColors: digitColors,
                        decimalPlaces: 400,
                        digitsPerRow: 19,
                        squareSize: 15.0,
                        currentNoteIndex: null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isPlayingAudio
                                ? _toggleAudioPlayback
                                : _repeatAudio,
                            icon: Icon(
                              _isPlayingAudio ? Icons.pause : Icons.replay,
                            ),
                            label: Text(
                              _isPlayingAudio ? "Pausar" : "Reproduzir",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text("Fechar"),
                            onPressed: () {
                              setState(() {
                                _activeChallengeType = null;
                                _isPlayingAudio =
                                    false; // Reseta o estado ao fechar
                                player?.stop(); // Para o áudio
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_activeChallengeType == 'sound')
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Desafio Som (Apenas Áudio)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Botão de Play/Pause
                      ElevatedButton.icon(
                        onPressed: _isPlayingAudio
                            ? _toggleAudioPlayback
                            : _repeatAudio,
                        icon: Icon(
                          _isPlayingAudio ? Icons.pause : Icons.replay,
                        ),
                        label: Text(
                          _isPlayingAudio ? "Pausar" : "Reproduzir",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text("Fechar"),
                            onPressed: () {
                              setState(() {
                                _activeChallengeType = null;
                                _isPlayingAudio =
                                    false; // Reseta o estado ao fechar
                                player?.stop(); // Para o áudio
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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
      _currentNoteIndex = -1;
    });

    if (key == 'save') {
      if (_controller.display != '0' && _controller.expression != '') {
        _controller.saveMosaic(_controller.expression, _controller.display,
            _squareSize, selectedInstrument, _noteDurationMs);
      }
    }
  }
}
