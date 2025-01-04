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
// import '../screens/responsive_calculator_screen.dart';

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
  // bool _isChallengeMinimized = false;
  bool _isMinimized = false;
  bool _ignoreZerosInAudio = false;

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
            mainAxisAlignment:
                MainAxisAlignment.center, // Centraliza verticalmente
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centraliza horizontalmente
            mainAxisSize:
                MainAxisSize.min, // Ajusta o tamanho da coluna ao conteúdo
            children: [
              const Text(
                "Escolha um Desafio",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Cor azul para o texto
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Espaço entre o título e o divisor
              const Divider(),
              const SizedBox(height: 20), // Espaço entre o divisor e os botões
              SizedBox(
                width: 400, // Define uma largura fixa para os botões
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor do botão
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordas arredondadas
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Desafio Padrão
                    _startStandardChallenge(context);
                  },
                  child: const Text(
                    "Mosaico ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white, // Texto branco
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Espaço entre os botões
              SizedBox(
                width: 400, // Define uma largura fixa para os botões
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor do botão
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordas arredondadas
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Desafio Som
                    print("Desafio Som selecionado");
                    _startSoundChallenge(context);
                  },
                  child: const Text(
                    "Som ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white, // Texto branco
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Espaço entre os botões
              SizedBox(
                width: 400, // Define uma largura fixa para os botões
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor do botão
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordas arredondadas
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Desafio Som e Imagem
                    print("Desafio Som e Imagem selecionado");
                    _startSoundAndImageChallenge(context);
                  },
                  child: const Text(
                    "Som e Mosaico",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white, // Texto branco
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

  void _startStandardChallenge(BuildContext context) {
    _controller.processKey('C', context);
    _generateChallengeMosaic(); // Gera o número decimal (periódico ou não periódico)

    setState(() {
      _activeChallengeType = 'standard'; // Tipo de desafio
    });
  }

  void _startSoundAndImageChallenge(BuildContext context) {
    _controller.processKey('C', context);
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

  void _startSoundChallenge(BuildContext context) {
    _controller.processKey('C', context);
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
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Stack(
                children: [
                  // Conteúdo principal (logos em uma linha)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Container(
                        padding:
                            const EdgeInsets.all(10.0), // Espaçamento interno
                        decoration: BoxDecoration(
                          color: Colors.white, // Fundo branco
                          borderRadius:
                              BorderRadius.circular(15), // Bordas arredondadas
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.2), // Sombra suave
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centraliza horizontalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centraliza verticalmente

                          children: [
                            // Primeiro logo
                            Image.asset(
                              'assets/images/IFSP_Logo.png',
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              width: 5,
                            ), // Espaçamento horizontal entre os logos
                            // Segundo logo
                            Image.asset(
                              'assets/images/CNPQ_Logo.png',
                              height:
                                  70, // Altere para ajustar proporcionalmente ao primeiro logo
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                                width:
                                    5), // Espaçamento adicional, se necessário
                            // Terceiro logo
                            Image.asset(
                              'assets/images/RUMO_Logo.png',
                              height:
                                  70, // Altere para ajustar proporcionalmente
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ),
                  // Botão de fechar no canto superior direito
                  Positioned(
                    bottom: 105,
                    left: 240,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Fecha o Drawer
                      },
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Menu',
                  style: const TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,// Ajusta o tamanho da fonte do item selecionado
                  )),
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0), // Espaçamento ao redor
             
                child: ListTile(
                  leading: const Icon(Icons.music_note),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0), // Padding interno do ListTile
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
                        print("Instrumento selecionado: $newInstrument");
                        setState(() {
                          selectedInstrument = newInstrument;
                        });
                        await SharedPreferencesService.saveInstrument(
                            newInstrument);
                        await initializeAudio();
                        print(
                            "Áudio reinicializado para o instrumento: $newInstrument");
                      }
                    },
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                    dropdownColor: Colors.blue,
                  ),
                ),
              
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0), // Espaçamento ao redor
             
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 0.0),
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
              
            ),
            const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //       horizontal: 8.0), // Espaçamento ao redor
             
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 0.0),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Slider(
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
                    ],
                  ),
                ),
              
            // ),
            const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //       horizontal: 8.0), // Espaçamento ao redor
              
                ListTile(
                  leading: const Icon(Icons.speed),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 0.0),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Slider(
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
                    ],
                  ),
                ),
              
            // ),

            const Divider(
              color: Colors.grey, // Cor da linha
              thickness: 1, // Espessura da linha
              indent: 20, // Espaçamento da esquerda
              endIndent: 20, // Espaçamento da direita
            ),

            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Mosaicos Salvos',
                  style: const TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,// Ajusta o tamanho da fonte do item selecionado
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
              leading: const Icon(Icons.flag), // Ícone representando desafios
              title: const Text(
                'Desafios',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Fecha o menu
                _showChallengesModal(); // Abre o modal de desafios
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text(
                'Instruções de Uso',
                style: TextStyle(fontSize: 20,),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UsageInstructionsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Alinha no final do menu
              children: [
                // Linha decorativa antes do item
                const Divider(
                  color: Colors.grey, // Cor da linha
                  thickness: 1, // Espessura da linha
                  indent: 20, // Espaçamento da esquerda
                  endIndent: 20, // Espaçamento da direita
                ),
                // Opção de agradecimentos
                ListTile(
                  title: const Center(
                    child: Text(
                      'Agradecimentos',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue, // Outra cor para o texto
                        fontWeight: FontWeight.bold,
                      ),
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
                // Linha decorativa abaixo do item
              ],
            ),
          ],
        ),
      ),
      body: Stack(
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
                      height: 25,
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

              SizedBox(
                height: MediaQuery.of(context).size.height > 740 &&
                        MediaQuery.of(context).size.width < 1024
                    ? 350
                    : 200,
                ////////////////////////////////////////////////////////////////////////////////// Mosaico
                // padding: const EdgeInsets.all(1.50),
                child: MosaicDisplay(
                  result:
                      _controller.isResultDisplayed ? _controller.display : '',
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
                //  width: 350,////////////////////////////////////////////////////////////////// slider padrão
                child: Row(
                  children: [
                    Text(
                      '$_mosaicDigitsPerRow',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,

                        fontSize:
                            30, ///////////////////////////////////////////////////////Fonte Slider
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _controller.mosaicDigitsPerRow.toDouble(),
                        min: 1,
                        max: 40,
                        label: _controller.mosaicDigitsPerRow.toString(),
                        onChanged: (double value) async {
                          setState(() {
                            _mosaicDigitsPerRow = value.toInt();
                            _controller.mosaicDigitsPerRow = value.toInt();
                            print(
                                "Valor do Slider alterado para: ${_controller.mosaicDigitsPerRow}");
                          });
                          await SharedPreferencesService.saveMosaicDigitsPerRow(
                              value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width > 1400 ? 100 : 50,
                ////////////////////////////////////////////////////////////////// botão play
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
              const SizedBox(
                  height:
                      10), ////////////////////////////////////altura entre o card
              SizedBox(
                // height: MediaQuery.of(context).size.width > 1400 ? 100 : 50,
                width: 310, // Largura fixa do Card
                height:
                    270, // Altura fixa do Card /////////////////////////////////////////////////////////////////////////////card
                child: Card(
                  color: const Color.fromARGB(255, 84, 173, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Bordas arredondadas, se necessário
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                          height:
                              8), ///////////////////////////////// diferença entre card e display da calculadora
                      SizedBox(
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(
                        //         8), // Espaçamento interno fixo
                        width:
                            280, /////////////////////////////////////////////////////////////////////////// Display Calculadora
                        height: 50, ///////////////////////Display Calculadora
                        child: ResultDisplay(
                          display: _controller.display,
                          operation: _controller.expression,
                          currentNoteIndex: _currentNoteIndex,
                          digitColors: _controller.digitColors,
                        ),
                        // ),
                      ),
                      const SizedBox(
                          height:
                              5), /////////////////////////////////////////////////////////////////////////// Diferença Display  e Botões Calculadora
                      SizedBox(
                        width:
                            280, /////////////////////////////////////////////////////////////////////////////////// botões calculadora
                        height: 190,
                        // child: Padding(
                        //   padding: const EdgeInsets.all(
                        //       12), // Espaçamento interno fixo
                        child: CalculatorKeypad(onKeyPressed: _handleKeyPress),
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
              //  const SizedBox(height: 20),
            ],
          ),
          if (_activeChallengeType == 'standard')
            Positioned(
              top: _isMinimized
                  ? null
                  : 25, // Define posição com base no estado minimizado
              bottom:
                  _isMinimized ? 10 : null, // Posiciona minimizado no rodapé
              left: MediaQuery.of(context).size.width > 1024
                  ? 500
                  : 0, // Ajusta margens laterais para telas largas
              right: MediaQuery.of(context).size.width > 1024
                  ? 500
                  : 0, // Ajusta margens laterais para telas largas
              child: Card(
                color: Colors.blue
                    .withOpacity(0.9), // Alterado para destacar mais o card
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Aumenta o arredondamento
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // Padding interno
                  child: _isMinimized
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Desafio Mosaico",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Cor para contraste
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.expand_more,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _isMinimized = false; // Restaura o modal
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _activeChallengeType =
                                          null; // Fecha o modal
                                      _isMinimized =
                                          false; // Reseta estado minimizado
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize
                              .min, // Ajusta o tamanho do card ao conteúdo
                          children: [
                            // Linha com ícones de minimizar e fechar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.expand_less,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _isMinimized = true; // Minimiza o modal
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _activeChallengeType =
                                          null; // Fecha o modal
                                      _isMinimized =
                                          false; // Reseta estado minimizado
                                    });
                                  },
                                ),
                              ],
                            ),
                            // Título centralizado
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                "Desafio Mosaico",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white, // Contraste com o fundo azul
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Exibição do mosaico
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
                            const SizedBox(
                                height: 20), // Espaço abaixo do mosaico
                          ],
                        ),
                ),
              ),
            ),
          if (_activeChallengeType == 'soundAndImage')
            Positioned(
              top: _isMinimized ? null : 25, // Ajusta posição ao minimizar
              bottom: _isMinimized ? 10 : null,
              left: MediaQuery.of(context).size.width > 1024
                  ? MediaQuery.of(context).size.width * 0.2
                  : 0,
              right: MediaQuery.of(context).size.width > 1024
                  ? MediaQuery.of(context).size.width * 0.2
                  : 0,
              child: Card(
                color: Colors.blue
                    .withOpacity(0.9), // Fundo azul para manter consistência
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Bordas arredondadas
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // Padding interno maior
                  child: _isMinimized
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Desafio Som e Mosaico",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.white, // Texto branco para contraste
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.expand_more,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _isMinimized = false; // Restaura o modal
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _activeChallengeType =
                                          null; // Fecha o modal
                                      _isMinimized =
                                          false; // Reseta estado minimizado
                                      _isPlayingAudio = false; // Para o áudio
                                      player?.stop(); // Para o áudio no player
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta o tamanho ao conteúdo
                          children: [
                            // Linha com ícones de minimizar e fechar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.expand_less,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _isMinimized = true; // Minimiza o modal
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _activeChallengeType =
                                          null; // Fecha o modal
                                      _isMinimized =
                                          false; // Reseta estado minimizado
                                      _isPlayingAudio = false; // Para o áudio
                                      player?.stop(); // Para o áudio no player
                                    });
                                  },
                                ),
                              ],
                            ),
                            // Título centralizado
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(
                                "Desafio Som e Mosaico",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white, // Contraste com o fundo azul
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Exibição do mosaico
                            MosaicDisplay(
                              result: _challengeMosaic,
                              digitColors: digitColors,
                              decimalPlaces: 400,
                              digitsPerRow: 19,
                              squareSize: MediaQuery.of(context).size.width <
                                      400
                                  ? 15.0
                                  : 20.0, // Ajuste dinâmico para telas menores
                              currentNoteIndex: null,
                            ),
                            const SizedBox(height: 20),
                            // Botão para controle de áudio
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
                            const SizedBox(height: 20), // Espaçamento final
                          ],
                        ),
                ),
              ),
            ),
          if (_activeChallengeType == 'sound')
            Positioned(
              top: _isMinimized ? null : 25, // Ajusta posição ao minimizar
              bottom: _isMinimized ? 10 : null,
              left: MediaQuery.of(context).size.width > 1024
                  ? MediaQuery.of(context).size.width * 0.2
                  : 0,
              right: MediaQuery.of(context).size.width > 1024
                  ? MediaQuery.of(context).size.width * 0.2
                  : 0,
              child: Card(
                color: Colors.blue
                    .withOpacity(0.9), // Fundo azul para consistência
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Bordas arredondadas
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // Padding interno maior
                  child: _isMinimized
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Desafio Som",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.white, // Texto branco para contraste
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.expand_more,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _isMinimized = false; // Restaura o modal
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _activeChallengeType =
                                          null; // Fecha o modal
                                      _isMinimized =
                                          false; // Reseta estado minimizado
                                      _isPlayingAudio = false; // Para o áudio
                                      player?.stop(); // Para o áudio no player
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta o tamanho ao conteúdo
                          children: [
                            // Linha com ícones de minimizar e fechar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.expand_less,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _isMinimized = true; // Minimiza o modal
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _activeChallengeType =
                                          null; // Fecha o modal
                                      _isMinimized =
                                          false; // Reseta estado minimizado
                                      _isPlayingAudio = false; // Para o áudio
                                      player?.stop(); // Para o áudio no player
                                    });
                                  },
                                ),
                              ],
                            ),
                            // Título centralizado
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(
                                "Desafio Som",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white, // Contraste com o fundo azul
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Botão para controle de áudio
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
                            const SizedBox(height: 20), // Espaçamento final
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
