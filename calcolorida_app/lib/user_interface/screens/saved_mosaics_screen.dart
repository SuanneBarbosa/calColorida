import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../widgets/mosaic_display.dart';
import '../../controllers/audio_controller.dart';

class SavedMosaicsScreen extends StatefulWidget {
  final CalculatorController controller;

  const SavedMosaicsScreen({Key? key, required this.controller}) : super(key: key);

  @override
  _SavedMosaicsScreenState createState() => _SavedMosaicsScreenState();
}

class _SavedMosaicsScreenState extends State<SavedMosaicsScreen> {
  int? _currentPlayingIndex; // Índice do mosaico que está tocando
  int? _currentNoteIndex; // Índice da nota atual sendo tocada
  bool _isPlaying = false; // Indica se algum áudio está tocando
  int _noteDurationMs = 500; // Duração das notas

  @override
  void initState() {
    super.initState();
    initializeAudio(); // Inicializa o áudio
  }

  @override
  void dispose() {
    disposeAudio(); // Libera recursos de áudio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Defina valores padrão para os parâmetros do mosaico
    final Map<String, Color> digitColors = widget.controller.digitColors;
    final int decimalPlaces = 400; // Ajuste conforme necessário
    final int digitsPerRow = 40;   // Ajuste conforme necessário
    final double squareSize = 10.0; // Ajuste conforme necessário

    return Scaffold(
      appBar: AppBar(
        title: Text('Mosaicos Salvos'),
      ),
      body: widget.controller.savedMosaics.isEmpty
          ? Center(
              child: Text(
                'Nenhum mosaico salvo.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: widget.controller.savedMosaics.length,
              itemBuilder: (context, index) {
                final mosaic = widget.controller.savedMosaics[index];
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(
                            'Operação: ${mosaic.operation}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeletion(index);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 200, // Ajuste conforme necessário
                          child: MosaicDisplay(
                            result: mosaic.result,
                            digitColors: digitColors,
                            decimalPlaces: decimalPlaces,
                            digitsPerRow: digitsPerRow,
                            squareSize: squareSize,
                            currentNoteIndex: _currentPlayingIndex == index ? _currentNoteIndex : null,
                            onNoteTap: null,
                            onMaxDigitsCalculated: null,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying && _currentPlayingIndex == index ? Icons.stop : Icons.play_arrow,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_isPlaying && _currentPlayingIndex == index) {
                                    // Parar a reprodução
                                    stopAudio();
                                    _isPlaying = false;
                                    _currentPlayingIndex = null;
                                    _currentNoteIndex = null;
                                  } else {
                                    // Parar qualquer reprodução em andamento
                                    stopAudio();
                                    _isPlaying = false;
                                    _currentPlayingIndex = null;
                                    _currentNoteIndex = null;

                                    // Iniciar a reprodução do mosaico selecionado
                                    _playSavedMosaic(mosaic.result, index);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeletion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Mosaico'),
          content: Text('Deseja realmente excluir este mosaico?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  widget.controller.deleteMosaic(index);
                });
                Navigator.of(context).pop();

                // Exibir mensagem de confirmação
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mosaico excluído com sucesso')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _playSavedMosaic(String result, int index) async {
    setState(() {
      _isPlaying = true;
      _currentPlayingIndex = index;
    });

    if (result.contains('.')) {
      String decimalPart = result.split('.')[1];
      decimalPart = decimalPart.replaceAll(RegExp(r'0+$'), '');

      List<int> digits = decimalPart.split('').map(int.parse).toList();

      if (digits.isEmpty) {
        print("Nenhum dígito para reproduzir após o ponto decimal.");
        setState(() {
          _isPlaying = false;
          _currentPlayingIndex = null;
        });
        return;
      }

      try {
        await playMelodyAudio(
          digits: digits,
          durationMs: _noteDurationMs,
          onNoteStarted: (noteIndex) {
            setState(() {
              _currentNoteIndex = noteIndex;
            });
          },
          onNoteFinished: (noteIndex) {
            setState(() {
              _currentNoteIndex = null;
            });
          },
          onPlaybackCompleted: () {
            setState(() {
              _isPlaying = false;
              _currentPlayingIndex = null;
              _currentNoteIndex = null;
            });
          },
        );
      } catch (e) {
        print("Erro ao reproduzir melodia: $e");
        setState(() {
          _isPlaying = false;
          _currentPlayingIndex = null;
        });
      }
    } else {
      print("O resultado não contém parte decimal.");
      setState(() {
        _isPlaying = false;
        _currentPlayingIndex = null;
      });
    }
  }
}
