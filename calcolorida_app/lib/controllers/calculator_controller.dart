import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:calcolorida_app/controllers/audio_controller.dart';
import 'package:calcolorida_app/models/mosaic_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/shared_preferences_service.dart';

class CalculatorController {
  String _display = '0';
  String _currentNumber = '';
  String _operation = '';
  Decimal _result = Decimal.zero;
  bool _hasDecimal = false;
  String _expression = '';
  int _decimalPlaces = 400;
  final int _maxDecimalPlaces = 400;
  bool _isResultDisplayed = false;
  double _squareSize = 20.0;
  int _noteDurationMs = 500;
  String _selectedInstrument = 'piano';
  int _mosaicDigitsPerRow = 19;
  bool _ignoreZeros = false;
  bool get ignoreZeros => _ignoreZeros;

  set ignoreZeros(bool value) {
    _ignoreZeros = value;
  }


  List<MosaicModel> savedMosaics = [];

  String get display => _display;
  String get expression => _expression;
  int get noteDurationMs => _noteDurationMs;
  String get selectedInstrument => _selectedInstrument;
  double get squareSize => _squareSize;
  bool get isResultDisplayed => _isResultDisplayed;
  int get mosaicDigitsPerRow => _mosaicDigitsPerRow;
  // bool get ignoreZeros => _ignoreZeros;

  // set ignoreZeros(bool value) {
  //   _ignoreZeros = value;
  // }

  set squareSize(double value) {
    _squareSize = value;
  }

  set selectedInstrument(String value) {
    _selectedInstrument = value;
  }

  set noteDurationMs(int value) {
    _noteDurationMs = value;
  }

  set mosaicDigitsPerRow(int value) {
    _mosaicDigitsPerRow = value;
  }

  Map<String, Color> digitColors = {
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

  void processKey(String key, BuildContext context) {
    const operations = ['+', '-', 'x', '/', '^'];
    bool isLastCharOperation() {
      if (_expression.isEmpty) return false;
      return operations.contains(_expression.trim().split('').last);
    }

    if (key == 'save') {
      return;
    }
    if (_operation.isEmpty &&
        _display == _result.toString() &&
        (key != 'C' &&
            key != '=' &&
            !['+', '-', 'x', '/', '^', '√', 'π', '1/x', '!', '<-', 'S']
                .contains(key))) {
      _clear();
    }
    if (key == 'C') {
      stopMelody();
      _clear();
    } else if (key == '=') {
      _calculate(context);
    } else if (operations.contains(key)) {
      if (isLastCharOperation()) {
      return; // Ignora a entrada
    }
      
      _setOperation(key, context);
      _expression += ' $key ';
    } else if (key == '.') {
      _isResultDisplayed = false;
      _addDecimal();
      _expression += key;
    } else if (key == '√') {
      _calculateSqrt(context);
      _expression =
          '√(${_currentNumber.isNotEmpty ? _currentNumber : _result.toString()})';
    } else if (key == 'π') {
      _insertPi();
      _expression += 'π';
    } else if (key == '1/x') {
      _calculateInverse(context);
      _expression =
          '1/(${_currentNumber.isNotEmpty ? _currentNumber : _result.toString()})';
    } else if (key == '!') {
      _calculateFactorial(context);
      _expression =
          '(${_currentNumber.isNotEmpty ? _currentNumber : _result.toString()})!';
    } else if (key == '<-') {
      if (_isResultDisplayed) {
      } else if (_currentNumber.isEmpty) {
      } else {
        _backspace();
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      }
    } else {
      _isResultDisplayed = false;
      _currentNumber += key;
      _expression += key;
    }
    _updateDisplay();
  }

  void _clear() {
    _currentNumber = '';
    _operation = '';
    _result = Decimal.zero;
    _hasDecimal = false;
    _expression = '';
    _display = '0';
    _isResultDisplayed = false;
  }

  void _calculate(BuildContext context) {
    if (_operation.isEmpty) {
      _showErrorModal(context, "Nenhuma operação foi definida.");
      return;
    }
    if (_currentNumber.isEmpty) {
      _showErrorModal(context, "Valor nulo ou vazio.");
      return;
    }

    try {
      Decimal secondNumber = Decimal.parse(_currentNumber);

      switch (_operation) {
        case '+':
          _result = _result + secondNumber;
          break;
        case '-':
          _result = _result - secondNumber;
          break;
        case 'x':
          _result = _result * secondNumber;
          break;
        case '/':
          if (secondNumber != Decimal.zero) {
            _result = (_result / secondNumber)
                .toDecimal(scaleOnInfinitePrecision: _decimalPlaces);
          } else {
            _showErrorModal(context, "Não é possível dividir por zero.");
            return;
          }
          break;
        case '^':
          try {
            int exponent = int.parse(secondNumber.toString());
            _result = _powDecimal(_result, exponent);
          } catch (e) {
            _showErrorModal(context, 'Expoente inválido');
            return;
          }
          break;
        default:
          _showErrorModal(context, "Operação inválida.");
          return;
      }

      _currentNumber = _result.toStringAsFixed(_decimalPlaces);
      _operation = '';
      _isResultDisplayed = true;
      _updateDisplay();
    } catch (e) {
      _showErrorModal(context, "Entrada inválida. Verifique os valores.");
    }
  }

  // ignore: unused_field
  bool _shouldStop = false;

  Future<void> playMelody({
    int durationMs = 500,
    int? maxDigits,
    Function(int noteIndex)? onNoteStarted,
    Function(int noteIndex)? onNoteFinished,
  }) async {
    if (!_isResultDisplayed) {
      print("O áudio só pode tocar após o resultado ser exibido.");
      return;
    }

    _shouldStop = false;

    if (_currentNumber.isNotEmpty && _currentNumber.contains('.')) {
      List<String> parts = _currentNumber.split('.');
      String decimalPart = parts[1].replaceAll(RegExp(r'0+$'), '');

      List<int> digitsToPlay = []; 

      if (_ignoreZeros) {
        digitsToPlay = decimalPart.split('').map(int.parse).where((digit) => digit != 0).toList();
      } else {
        digitsToPlay = decimalPart.split('').map(int.parse).toList();
      }

      if (digitsToPlay.isEmpty) {
        print("Nenhum dígito para reproduzir após o ponto decimal.");
        return;
      }

      List<int> originalDigits = decimalPart.split('').map(int.parse).toList();


      if (maxDigits != null && decimalPart.length > maxDigits) {
        decimalPart = decimalPart.substring(0, maxDigits);

        if (_ignoreZeros) {
           digitsToPlay = digitsToPlay.sublist(0, maxDigits);
        } else {
           digitsToPlay = digitsToPlay.sublist(0, maxDigits); //ou original digits, se necessário.
        }

      }

      try {
        await playMelodyAudio(
          digits: digitsToPlay,
          durationMs: durationMs,
          onNoteStarted: (noteIndex) {
            if (onNoteStarted != null) {
              int originalIndex = 0;
              if(_ignoreZeros){
                int nonZeroCount = 0;
                for(int i =0; i<originalDigits.length; i++){
                    if(originalDigits[i]!=0){
                        if(nonZeroCount == noteIndex){
                          originalIndex = i;
                          break;
                        }
                         nonZeroCount++;
                    }

                }

              }else{
                 originalIndex = noteIndex;
              }

                onNoteStarted(originalIndex);
            }
          },
          onNoteFinished: onNoteFinished,
        );
      } catch (e) {
        print("Erro ao reproduzir melodia: $e");
      }
    }
  }

  



  Future<void> stopMelody() async {
    stopPlayback();
    await stopAudio();
  }

  void _setOperation(String op, BuildContext context) {
    _isResultDisplayed = false;
    if (_currentNumber.isNotEmpty) {
      if (_operation.isNotEmpty) {
        _calculate(context);
      } else {
        try {
          _result = Decimal.parse(_currentNumber);
        } catch (e) {
          _display = 'Erro';
          return;
        }
      }
      _operation = op;
      _currentNumber = '';
      _hasDecimal = false;
    }
  }

  void _addDecimal() {
    if (!_hasDecimal) {
      if (_currentNumber.isEmpty) {
        _currentNumber = '0.';
      } else {
        _currentNumber += '.';
      }
      _hasDecimal = true;
    }
  }

  void _applyDecimalPlaces() {
    if (_decimalPlaces < 0) {
      _decimalPlaces = 0;
    }
    _updateDisplay();
  }

  void setDecimalPlaces(int decimalPlaces) {
    if (decimalPlaces >= 0 && decimalPlaces <= _maxDecimalPlaces) {
      _decimalPlaces = decimalPlaces;
    }
    _applyDecimalPlaces();
  }

  // void _updateDisplay() {
  //   if (_currentNumber.isEmpty) {
  //     _display = _result.toStringAsFixed(_decimalPlaces);
  //   } else {
  //     _display = _currentNumber;
  //   }

  //   if (_display.endsWith('.')) {
  //     _display = _display.substring(0, _display.length - 1);
  //   }

  //   if (_display.contains('.')) {
  //     _display = _display.replaceAll(RegExp(r'\.?0+$'), '');
  //   }

  //   if (_display.endsWith('.0')) {
  //     _display = _display.substring(0, _display.length - 2);
  //   }
  // }

  void _updateDisplay() {
    if (_currentNumber.isEmpty) {
      _display = _result.toStringAsFixed(_decimalPlaces);
      _display = _display.replaceAll(RegExp(r'0+$'), '');
      if (_display.endsWith('.')) {
        _display = _display.substring(0, _display.length - 1);
      }
    } else {
      _display = _currentNumber;
    }

    // Remove zeros à direita apenas se há números depois do ponto decimal
    print(_display);
    if (_isResultDisplayed) {
      _display = _display.replaceAll(RegExp(r'0+$'), '');
      if (_display.endsWith('.')) {
        _display = _display.substring(0, _display.length - 1);
      }
    }
  }

  void _calculateSqrt(BuildContext context) {
    if (_currentNumber.isEmpty) {
      _showErrorModal(context, "Valor nulo.");
      return;
    }

    try {
      Decimal number = Decimal.parse(_currentNumber);

      if (number < Decimal.zero) {
        _showErrorModal(context, "Número negativo.");

        return;
      }

      Decimal sqrtResult = _sqrtNewtonRaphson(number, _decimalPlaces);
      _result = sqrtResult;
      _currentNumber = _result.toStringAsFixed(_decimalPlaces);
      _isResultDisplayed = true;
      _updateDisplay();
    } catch (e) {
      _showErrorModal(context, "Erro: Entrada Inválida.");
    }
  }

  Decimal _sqrtNewtonRaphson(Decimal value, int decimalPlaces) {
    if (value < Decimal.zero) {
      throw ArgumentError(
          'Não é possível calcular a raiz quadrada de um número negativo');
    } else if (value == Decimal.zero) {
      return Decimal.zero;
    }

    Decimal two = Decimal.fromInt(2);
    Decimal guess =
        (value / two).toDecimal(scaleOnInfinitePrecision: decimalPlaces);
    Decimal lastGuess;

    int maxIterations = 400;
    int iteration = 0;

    while (true) {
      lastGuess = guess;
      guess = ((guess +
                  (value / guess)
                      .toDecimal(scaleOnInfinitePrecision: decimalPlaces)) /
              two)
          .toDecimal(scaleOnInfinitePrecision: decimalPlaces);

      iteration++;
      if (iteration > maxIterations) {
        break;
      }

      Decimal difference = (guess - lastGuess).abs();
      Decimal epsilon = Decimal.parse('1e-${decimalPlaces + 1}');
      if (difference < epsilon) {
        break;
      }
    }

    return Decimal.parse(guess.toStringAsFixed(decimalPlaces));
  }

  void _insertPi() {
    final Decimal piDecimal = Decimal.parse(
        '3.14159265358979323846264338327950288419716939937510582097494459230');

    if (_currentNumber.isEmpty) {
      _currentNumber = piDecimal.toStringAsFixed(_decimalPlaces);
    } else {
      _currentNumber += piDecimal.toStringAsFixed(_decimalPlaces);
    }
  }

  void _calculateInverse(BuildContext context) {
    if (_currentNumber.isEmpty) {
      _showErrorModal(context, "Erro: Valor Nulo.");
      return;
    }

    try {
      Decimal number = Decimal.parse(_currentNumber);
      if (number != Decimal.zero) {
        _result = (Decimal.one / number)
            .toDecimal(scaleOnInfinitePrecision: _decimalPlaces);
        _currentNumber = _result.toStringAsFixed(_decimalPlaces);
        _isResultDisplayed = true;
        _updateDisplay();
      } else {
        _showErrorModal(context, "Erro: Divisão por zero.");
      }
    } catch (e) {
      _showErrorModal(context, "Erro: Entrada Inválida.");
    }
  }

  void _calculateFactorial(BuildContext context) {
    if (_currentNumber.isEmpty) {
      _showErrorModal(context, "Erro: Valor Nulo.");
      return;
    }

    try {
      Decimal numberDecimal = Decimal.parse(_currentNumber);
      if ((numberDecimal % Decimal.one) != Decimal.zero) {
        _showErrorModal(context, "Erro: Entrada não é um inteiro.");
        return;
      }

      BigInt number = numberDecimal.toBigInt();
      if (number >= BigInt.zero) {
        BigInt factorialResult = _factorial(number);
        _result = Decimal.fromBigInt(factorialResult);
        _currentNumber = _result.toString();
        _isResultDisplayed = true;
        _updateDisplay();
      } else {
        _showErrorModal(context, "Erro: Número Negativo.");
      }
    } catch (e) {
      _showErrorModal(context, "Erro: Entrada Inválida");
    }
  }

  BigInt _factorial(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError('Número negativo não permitido.');
    BigInt result = BigInt.one;
    for (BigInt i = BigInt.one; i <= n; i = i + BigInt.one) {
      result *= i;
    }
    return result;
  }

  void _backspace() {
    if (_currentNumber.isNotEmpty) {
      if (_currentNumber.endsWith('.')) {
        _hasDecimal = false;
      }
      _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
    }
    _updateDisplay();
  }

  Decimal _powDecimal(Decimal base, int exponent) {
    return base
        .pow(exponent)
        .toDecimal(scaleOnInfinitePrecision: _decimalPlaces);
  }

  Future<void> saveMosaic(String operation, String result, double squareSize,
      String instrument, int noteDurationMs, int mosaicDigitsPerRow) async {
    savedMosaics.add(MosaicModel(
      operation: operation,
      result: result,
      squareSize: squareSize,
      instrument: instrument,
      noteDurationMs: noteDurationMs,
      mosaicDigitsPerRow: mosaicDigitsPerRow,
    ));
    final prefs = await SharedPreferences.getInstance();
    final mosaicList = savedMosaics.map((mosaic) => mosaic.toJson()).toList();
    await prefs.setStringList(
        'savedMosaics', mosaicList.map((e) => jsonEncode(e)).toList());
    await saveSettings();
  }

  Future<void> saveSettings() async {
    await SharedPreferencesService.saveResult(_display);
    await SharedPreferencesService.saveOperation(_expression);
    await SharedPreferencesService.saveZoom(squareSize);
    await SharedPreferencesService.saveInstrument(selectedInstrument);
    await SharedPreferencesService.saveNoteDuration(_noteDurationMs);
    await SharedPreferencesService.saveMosaicDigitsPerRow(_mosaicDigitsPerRow);
  }

  Future<void> loadSettings() async {
    _display = await SharedPreferencesService.getResult() ?? "0";
    _expression = await SharedPreferencesService.getOperation() ?? "";
    _squareSize = await SharedPreferencesService.getZoom() ?? _squareSize;
    _selectedInstrument =
        await SharedPreferencesService.getInstrument() ?? _selectedInstrument;
    _noteDurationMs =
        await SharedPreferencesService.getNoteDuration() ?? _noteDurationMs;
    _mosaicDigitsPerRow =
        await SharedPreferencesService.getMosaicDigitsPerRow() ??
            _mosaicDigitsPerRow; // Carrega
  }

  Future<void> _saveMosaicsToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final mosaicList = savedMosaics.map((mosaic) => mosaic.toJson()).toList();
    await prefs.setStringList(
        'savedMosaics', mosaicList.map((e) => jsonEncode(e)).toList());
  }

  void deleteMosaic(int index) async {
    if (index >= 0 && index < savedMosaics.length) {
      savedMosaics.removeAt(index);
      await _saveMosaicsToPreferences(); // Salva a lista atualizada
    }
  }

  void loadMosaic(String operation, String result) {
    print('Carregando mosaico no controlador');

    _expression = operation;
    _currentNumber = result;
    _result = Decimal.parse(result);
    _isResultDisplayed = true;
    _updateDisplay();
  }

   void loadFixedMosaics() {
  final fixedMosaics = [
    MosaicModel(
      operation: "10228 / 99999",
      result: "0.1022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228102281022810228",
      squareSize: 20.0,
      instrument: "piano",
      noteDurationMs: 500,
      mosaicDigitsPerRow: 20,
      isFixed: true,
    ),
    
    MosaicModel(
      operation: "7 / 8",
      result: "1.1428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428",
      squareSize: 20.0,
      instrument: "violino",
      noteDurationMs: 500,
      mosaicDigitsPerRow: 19,
      isFixed: true,
    ),
  ];

  savedMosaics.insertAll(0, fixedMosaics);
}

  Future<void> loadMosaics() async {
     loadFixedMosaics(); // Carrega os mosaicos fixos primeiro
    final prefs = await SharedPreferences.getInstance();
    final mosaicListJson = prefs.getStringList('savedMosaics');

    if (mosaicListJson != null) {
      savedMosaics = mosaicListJson.map((mosaicJson) {
        final mosaicMap = jsonDecode(mosaicJson);
        return MosaicModel.fromJson(mosaicMap);
      }).toList();
    }
  }

  //Mensagens de Erro:
  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar clicando fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verifique o Erro."),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool hasActiveMosaic() {
    return _isResultDisplayed && _display.contains('.');
  }
}
