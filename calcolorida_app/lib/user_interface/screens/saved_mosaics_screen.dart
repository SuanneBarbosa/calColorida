import 'package:calcolorida_app/models/mosaic_model.dart';
import 'package:flutter/material.dart';
import '../../controllers/calculator_controller.dart';
import '../widgets/mosaic_display.dart';
import '../../controllers/audio_controller.dart';

class SavedMosaicsScreen extends StatefulWidget {
  final CalculatorController controller;
  final VoidCallback? onMosaicApplied;

  const SavedMosaicsScreen(
      {super.key, required this.controller, this.onMosaicApplied});

  @override
  _SavedMosaicsScreenState createState() => _SavedMosaicsScreenState();
}

class _SavedMosaicsScreenState extends State<SavedMosaicsScreen> {
  int? _currentPlayingIndex;
  int? _currentNoteIndex;
  // bool _isPlaying = false;
  // int _noteDurationMs = 500;

  @override
  void initState() {
    super.initState();
    initializeMainAudio();
  initializeChallengeAudio();
  }

  @override
  void dispose() {
    disposeAllAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> digitColors = widget.controller.digitColors;
    const int decimalPlaces = 400;
    // const int digitsPerRow = 40;
    const double squareSize = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mosaicos Salvos'),
      ),
      body: widget.controller.savedMosaics.isEmpty
          ? const Center(
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
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: mosaic.isFixed
                        ? Colors.blue.shade50
                        : Colors.white, // Cor diferente para mosaicos fixos
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _applySavedMosaic(mosaic);
                                    print(
                                        'Aplicando mosaico: operação=${mosaic.operation}, resultado=${mosaic.result}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  child: const Text('Aplicar'),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: mosaic.isFixed
                                        ? Colors.grey
                                        : Colors.red,
                                    size: 35,
                                  ),
                                  onPressed: mosaic.isFixed
                                      ? null 
                                      : () {
                                          _confirmDeletion(index);
                                        },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: MosaicDisplay(
                              result: mosaic.result,
                              digitColors: digitColors,
                              decimalPlaces: decimalPlaces,
                              digitsPerRow: mosaic.mosaicDigitsPerRow,
                              squareSize: squareSize,
                              currentNoteIndex: _currentPlayingIndex == index
                                  ? _currentNoteIndex
                                  : null,
                              onNoteTap: null,
                              onMaxDigitsCalculated: null,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Operação: ${mosaic.operation}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
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
          title: const Text('Excluir Mosaico'),
          content: const Text('Deseja realmente excluir este mosaico?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  widget.controller.deleteMosaic(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mosaico excluído com sucesso')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _applySavedMosaic(MosaicModel mosaic) async {
    widget.controller.loadMosaic(mosaic.operation, mosaic.result);
    widget.controller.squareSize = mosaic.squareSize;
    widget.controller.selectedInstrument = mosaic.instrument;
    widget.controller.noteDurationMs = mosaic.noteDurationMs;
    widget.controller.mosaicDigitsPerRow = mosaic.mosaicDigitsPerRow;

    // setState(() {
    //   _mosaicDigitsPerRow = mosaic.mosaicDigitsPerRow;
    // });

    await widget.controller.saveSettings();

    widget.onMosaicApplied?.call();
    Navigator.pop(context);

    await initializeMainAudio();
    await initializeChallengeAudio();
  }
}
