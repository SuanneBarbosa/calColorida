import 'dart:math';
import 'package:calcolorida_app/controllers/audio_controller.dart';
import 'package:calcolorida_app/user_interface/screens/instructions_screen.dart';
import 'package:calcolorida_app/user_interface/screens/tanks_screen.dart';
import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../../services/shared_preferences_service.dart';
import '../screens/saved_mosaics_screen.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/result_display.dart';
import '../widgets/mosaic_display.dart';

enum LayoutType { mobile, tablet, desktop }

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
  final bool _showChallengeMosaic = false;
  String _challengeMosaic = "";
  String? _activeChallengeType;
  bool _isPlayingAudio = false;
  bool _isMinimized = false;
  bool _ignoreZerosInAudio = false;
  int _delayBetweenNotesMs = 0;

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
    final mosaicDigitsPerRow =
        await SharedPreferencesService.getMosaicDigitsPerRow();

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
      if (mosaicDigitsPerRow != null) {
        _mosaicDigitsPerRow = mosaicDigitsPerRow;
        _controller.mosaicDigitsPerRow = mosaicDigitsPerRow;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Escolha um Desafio",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    _startStandardChallenge(context);
                  },
                  child: const Text(
                    "Mosaico ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _startSoundChallenge(context);
                  },
                  child: const Text(
                    "Som ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _startSoundAndImageChallenge(context);
                  },
                  child: const Text(
                    "Som e Mosaico",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

//Gerador de Desafio
  void _generateChallengeMosaic() {
    final rand = Random();
    const length = 247; //
    String randomMosaic = "";
    bool isPeriodic = rand.nextBool();

    if (isPeriodic) {
      int periodLength = rand.nextInt(5) + 1;
      String period = "";
      for (int i = 0; i < periodLength; i++) {
        period += rand.nextInt(10).toString();
      }
      while (randomMosaic.length < length) {
        randomMosaic += period;
      }
      randomMosaic = randomMosaic.substring(0, length);
    } else {
      for (int i = 0; i < length; i++) {
        randomMosaic += rand.nextInt(10).toString();
      }
    }

    _challengeMosaic = "0.$randomMosaic";
  }

  void _toggleAudioPlayback() {
    if (_isPlayingAudio) {
      player?.pause();
      setState(() {
        _isPlayingAudio = false;
      });
    } else {
      player?.play();
      setState(() {
        _isPlayingAudio = true;
      });
    }
  }

  void _repeatAudio() {
    String decimalPart = _challengeMosaic.split('.')[1];
    List<int> digits = decimalPart.split('').map(int.parse).toList();

    playMelodyAudio(
      digits: digits,
      durationMs: 500,
      delayMs: 0,
      onNoteStarted: (noteIndex) {},
      onNoteFinished: (noteIndex) {},
      onPlaybackCompleted: () {
        setState(() {
          _isPlayingAudio = false;
        });
      },
    );

    setState(() {
      _isPlayingAudio = true;
    });
  }

  void _startStandardChallenge(BuildContext context) {
    _controller.processKey('C', context);
    _generateChallengeMosaic();

    setState(() {
      _activeChallengeType = 'standard';
    });
  }

  void _startSoundAndImageChallenge(BuildContext context) {
    _controller.processKey('C', context);
    _generateChallengeMosaic();

    setState(() {
      _activeChallengeType = 'soundAndImage';
      _isPlayingAudio = true;
    });

    String decimalPart = _challengeMosaic.split('.')[1];
    List<int> digits = decimalPart.split('').map(int.parse).toList();

    playMelodyAudio(
      digits: digits,
      durationMs: 500,
      delayMs: 0,
      onNoteStarted: (noteIndex) {},
      onNoteFinished: (noteIndex) {},
      onPlaybackCompleted: () {
        setState(() {
          _isPlayingAudio = false;
        });
      },
    );
  }

  void _startSoundChallenge(BuildContext context) {
    _controller.processKey('C', context);
    _generateChallengeMosaic();

    setState(() {
      _activeChallengeType = 'sound';
      _isPlayingAudio = true;
    });

    String decimalPart = _challengeMosaic.split('.')[1];
    List<int> digits = decimalPart.split('').map(int.parse).toList();

    playMelodyAudio(
      digits: digits,
      durationMs: 500,
      delayMs: 0,
      onPlaybackCompleted: () {
        setState(() {
          _isPlayingAudio = false;
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
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/IFSP_Logo.png',
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              'assets/images/CNPQ_Logo.png',
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 5),
                            Image.asset(
                              'assets/images/RUMO_Logo.png',
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 105,
                    left: 240,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.zoom_in),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _squareSize,
                      min: _minSquareSize,
                      max: _maxSquareSize,
                      divisions: 100,
                      label: 'Zoom do Mosaico',
                      onChanged: (double value) async {
                        setState(() {
                          _squareSize = value;
                        });
                        await SharedPreferencesService.saveZoom(value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.hourglass_empty),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _delayBetweenNotesMs.toDouble(),
                      min: 0,
                      max: 5000,
                      divisions: 50,
                      label: 'Tempo Entre Notas',
                      onChanged: (double value) {
                        setState(() {
                          _delayBetweenNotesMs = value.toInt();
                          _controller.delayBetweenNotesMs =
                              _delayBetweenNotesMs;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.speed),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: (3000 - _noteDurationMs).toDouble(),
                      min: 0,
                      max: 2900,
                      divisions: 100,
                      label: 'Velocidade de Reprodução',
                      onChanged: (value) async {
                        setState(() {
                          _noteDurationMs = 3000 - value.toInt();
                        });
                        await SharedPreferencesService.saveNoteDuration(
                            _noteDurationMs);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),

            ListTile(
              leading: const Icon(Icons.music_note),
              subtitle: DropdownButton<String>(
                isExpanded: true,
                value: selectedInstrument,
                items: instrumentFileNameMap.keys
                    .map<DropdownMenuItem<String>>((String instrument) {
                  return DropdownMenuItem<String>(
                    value: instrument,
                    child: Text(
                      instrumentDisplayNameMap[instrument] ?? instrument,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newInstrument) async {
                  if (newInstrument != null) {
                    setState(() {
                      selectedInstrument = newInstrument;
                    });
                    await SharedPreferencesService.saveInstrument(
                        newInstrument);
                    await initializeAudio();
                  }
                },
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
                dropdownColor: Colors.blue,
              ),
            ),

            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ignorar Zeros',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Switch(
                    value: _ignoreZerosInAudio,
                    onChanged: (bool value) {
                      setState(() {
                        _ignoreZerosInAudio = value;
                        _controller.ignoreZeros = _ignoreZerosInAudio;
                      });
                    },
                  ),
                ],
              ),
            ),

            // ),

            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),

            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Mosaicos Salvos',
                  style: const TextStyle(
                    fontSize: 20,
                  )),
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
                        final digitsPerRow = await SharedPreferencesService
                            .getMosaicDigitsPerRow();

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
                          if (digitsPerRow != null) {
                            _mosaicDigitsPerRow = digitsPerRow;
                            _controller.mosaicDigitsPerRow = digitsPerRow;
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
              title: const Text(
                'Desafios',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showChallengesModal();
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text(
                'Instruções de Uso',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UsageInstructionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.handshake),
              title: const Text(
                'Agradecimentos',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThankYouScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                if (_colorLegendExpanded)
                  Wrap(
                    spacing: 2.0,
                    runSpacing: 3.0,
                    children: digitColors.entries.map((entry) {
                      return Container(
                        width: 30,
                        height: 22,
                        decoration: BoxDecoration(
                          color: entry.value,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height > 740 &&
                          MediaQuery.of(context).size.width < 1024
                      ? 330
                      : 200,
                  child: MosaicDisplay(
                    result: _controller.isResultDisplayed
                        ? _controller.display
                        : '',
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
                SizedBox(
                  width: MediaQuery.of(context).size.width > 711 ? 600 : 350,
                  height: 50,
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
                          value: _controller.mosaicDigitsPerRow.toDouble(),
                          min: 1,
                          max: 40,
                          divisions: 100,
                          label: 'Padrões do Mosaico',
                          onChanged: (double value) async {
                            setState(() {
                              _mosaicDigitsPerRow = value.toInt();
                              _controller.mosaicDigitsPerRow = value.toInt();
                            });
                            await SharedPreferencesService
                                .saveMosaicDigitsPerRow(value.toInt());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width > 1400 ? 100 : 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              _controller.stopMelody();
                              _isPlaying = false;
                              _currentNoteIndex = null;
                            } else {
                              _controller.playMelody(
                                durationMs: _noteDurationMs,
                                maxDigits: _maxDigitsInMosaic,
                                delayMs: _delayBetweenNotesMs,
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
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 310,
                  height: 270,
                  child: Card(
                    color: const Color.fromARGB(255, 84, 173, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 280,
                          height: 50,
                          child: ResultDisplay(
                            display: _controller.display,
                            operation: _controller.expression,
                            currentNoteIndex: _currentNoteIndex,
                            digitColors: _controller.digitColors,
                          ),
                          // ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 280,
                          height: 190,
                          child:
                              CalculatorKeypad(onKeyPressed: _handleKeyPress),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_activeChallengeType == 'standard')
              Positioned(
                top: _isMinimized ? null : 25,
                bottom: _isMinimized ? 10 : null,
                left: MediaQuery.of(context).size.width > 1024
                    ? MediaQuery.of(context).size.width * 0.2
                    : 0,
                right: MediaQuery.of(context).size.width > 1024
                    ? MediaQuery.of(context).size.width * 0.2
                    : 0,
                child: Card(
                  color: Colors.blue.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _isMinimized
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Desafio Mosaico",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.expand_more,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isMinimized = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _activeChallengeType = null;
                                        _isMinimized = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.expand_less,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isMinimized = true;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _activeChallengeType = null;
                                        _isMinimized = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  "Desafio Mosaico",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              MosaicDisplay(
                                result: _challengeMosaic,
                                digitColors: digitColors,
                                decimalPlaces: 400,
                                digitsPerRow: _mosaicDigitsPerRow,
                                squareSize:
                                    MediaQuery.of(context).size.width < 400
                                        ? 15.0
                                        : 20.0,
                                currentNoteIndex: null,
                                onNoteTap: null,
                                onMaxDigitsCalculated: null,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),
              ),
            if (_activeChallengeType == 'soundAndImage')
              Positioned(
                top: _isMinimized ? null : 25,
                bottom: _isMinimized ? 10 : null,
                left: MediaQuery.of(context).size.width > 1024
                    ? MediaQuery.of(context).size.width * 0.2
                    : 0,
                right: MediaQuery.of(context).size.width > 1024
                    ? MediaQuery.of(context).size.width * 0.2
                    : 0,
                child: Card(
                  color: Colors.blue.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _isMinimized
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Desafio Som e Mosaico",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.expand_more,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isMinimized = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _activeChallengeType = null;
                                        _isMinimized = false;
                                        _isPlayingAudio = false;
                                        player?.stop();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.expand_less,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isMinimized = true;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _activeChallengeType = null;
                                        _isMinimized = false;
                                        _isPlayingAudio = false;
                                        player?.stop();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  "Desafio Som e Mosaico",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                              MosaicDisplay(
                                result: _challengeMosaic,
                                digitColors: digitColors,
                                decimalPlaces: 400,
                                digitsPerRow: _mosaicDigitsPerRow,
                                squareSize:
                                    MediaQuery.of(context).size.width < 400
                                        ? 15.0
                                        : 20.0,
                                currentNoteIndex: null,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isPlayingAudio
                                        ? _toggleAudioPlayback
                                        : _repeatAudio,
                                    icon: Icon(
                                      _isPlayingAudio
                                          ? Icons.pause
                                          : Icons.replay,
                                    ),
                                    label: Text(
                                      _isPlayingAudio ? "Pausar" : "Reproduzir",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),
              ),
            if (_activeChallengeType == 'sound')
              Positioned(
                top: _isMinimized ? null : 25,
                bottom: _isMinimized ? 10 : null,
                left: MediaQuery.of(context).size.width > 1024
                    ? MediaQuery.of(context).size.width * 0.2
                    : 0,
                right: MediaQuery.of(context).size.width > 1024
                    ? MediaQuery.of(context).size.width * 0.2
                    : 0,
                child: Card(
                  color: Colors.blue.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _isMinimized
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Desafio Som",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.expand_more,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isMinimized = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _activeChallengeType = null;
                                        _isMinimized = false;
                                        _isPlayingAudio = false;
                                        player?.stop();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.expand_less,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isMinimized = true;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _activeChallengeType = null;
                                        _isMinimized = false;
                                        _isPlayingAudio = false;
                                        player?.stop();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  "Desafio Som",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isPlayingAudio
                                        ? _toggleAudioPlayback
                                        : _repeatAudio,
                                    icon: Icon(
                                      _isPlayingAudio
                                          ? Icons.pause
                                          : Icons.replay,
                                    ),
                                    label: Text(
                                      _isPlayingAudio ? "Pausar" : "Reproduzir",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleKeyPress(String key) {
    setState(() {
      _controller.processKey(key, context);
      _currentNoteIndex = -1;
    });

    if (key == 'save') {
      if (_controller.hasActiveMosaic()) {
        _controller.saveMosaic(
          _controller.expression,
          _controller.display,
          _squareSize,
          selectedInstrument,
          _noteDurationMs,
          _mosaicDigitsPerRow,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mosaico salvo com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum mosaico na tela para salvar.')),
        );
      }
    }
  }
}
