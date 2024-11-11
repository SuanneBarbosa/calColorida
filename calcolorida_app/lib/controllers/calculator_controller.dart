// import 'dart:math';
import 'package:calcolorida_app/constants/constants.dart';
import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

import 'package:decimal/decimal.dart'; // Certifique-se de usar a versão 3.0.2
import 'package:calcolorida_app/controllers/audio_controller.dart';

// import 'package:calcolorida_app/constants/constants.dart'; // Importar digitToNote
class CalculatorController {
  String _display = '0';
  String _currentNumber = '';
  String _operation = '';
  Decimal _result = Decimal.zero; // Usando Decimal para maior precisão
  bool _hasDecimal = false;
  String _expression = '';
  int _decimalPlaces = 750; // Número padrão de casas decimais
  int _maxDecimalPlaces = 750; // Máximo de casas decimais permitidas
  bool _isResultDisplayed = false; 

  // Getters para o display e a expressão atual
  String get display => _display;
  String get expression => _expression;

  // Mapa de cores para os dígitos
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

  // Função para processar teclas pressionadas
  void processKey(String key) {
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
      _calculate();
    } else if (['+', '-', 'x', '/', '^'].contains(key)) {
      _setOperation(key);
      _expression += ' $key ';
    } else if (key == '.') {
      _isResultDisplayed = false; // Redefine o flag
      _addDecimal();
      _expression += key;
    } else if (key == '√') {
      _calculateSqrt();
      _expression = '√($_expression)';
    } else if (key == 'π') {
      _insertPi();
      _expression += 'π';
    } else if (key == '1/x') {
      _calculateInverse();
      _expression = '1/($_expression)';
    } else if (key == '!') {
      _calculateFactorial();
      _expression += '!';
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
      // Adiciona um dígito ao número atual
      _isResultDisplayed = false; // Redefine o flag
      if (_operation.isEmpty) {
        _currentNumber += key;
      } else {
        _currentNumber += key;
      }
      _expression += key;
    }
    // _isResultDisplayed = true; // Marca que o resultado está na tela
    _updateDisplay();
  }

  // Função para limpar a calculadora
  void _clear() {
    _currentNumber = '';
    _operation = '';
    _result = Decimal.zero;
    _hasDecimal = false;
    _expression = '';
    _display = '0';
    _isResultDisplayed = false; // Redefine o flag
  }

  // Função para calcular o resultado com base na operação atual
  void _calculate() {
    if (_operation.isEmpty) return;
    Decimal secondNumber =
        Decimal.parse(_currentNumber); // Converte para Decimal

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
          _display = 'Erro: Divisão por zero';
          return;
        }
        break;
      case '^':
        _result = _powDecimal(_result, int.parse(secondNumber.toString()));
        break;
    }
    _currentNumber = _result.toStringAsFixed(_decimalPlaces);
    _operation = '';
    _expression = '';
    _isResultDisplayed = true; 
    _updateDisplay();
  }

  
  
  bool _shouldStop = false;

  Future<void> playMelody() async {
    if (!_isResultDisplayed) {
    print("O áudio só pode tocar após o resultado ser exibido.");
    return;
  }
  _shouldStop = false;
  if (_currentNumber.isNotEmpty && _currentNumber.contains('.')) {
    List<String> parts = _currentNumber.split('.');
    String decimalPart = parts[1];
    decimalPart = decimalPart.replaceAll(RegExp(r'0+$'), '');

    for (int i = 0; i < decimalPart.length; i++) {
      if (_shouldStop) break;
      String char = decimalPart[i];
      if (RegExp(r'[0-9]').hasMatch(char)) {
        int digit = int.parse(char);
        print('Tocando nota para o dígito $digit: ${digitToNote[digit]}');
        await playNoteForNumber(digit); 
        if (_shouldStop) break; 
        // await Future.delayed(Duration(milliseconds: 200)); // Intervalo entre notas
      }
    }
  }
  await stopAudio();
}

  Future<void> stopMelody() async {
    _shouldStop = true; // Definir o flag para interromper a reprodução
    await stopAudio(); // Parar qualquer nota que esteja tocando
  }

  // Função para definir a operação matemática
  void _setOperation(String op) {
    _isResultDisplayed = false; // Redefine o flag
    if (_currentNumber.isNotEmpty) {
      if (_operation.isNotEmpty) {
        _calculate();
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

  // Função para adicionar um ponto decimal
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

  // Função para aplicar o número de casas decimais
  void _applyDecimalPlaces() {
    if (_decimalPlaces < 0) {
      _decimalPlaces = 0;
    }
    _updateDisplay();
  }

  // Função para definir o número de casas decimais
  void setDecimalPlaces(int decimalPlaces) {
    if (decimalPlaces >= 0 && decimalPlaces <= _maxDecimalPlaces) {
      _decimalPlaces = decimalPlaces;
    }
    _applyDecimalPlaces();
  }

  // Função para atualizar o display com o valor atual
  void _updateDisplay() {
    if (_currentNumber.isEmpty) {
      _display = _result.toStringAsFixed(_decimalPlaces);
    } else {
      _display = _currentNumber;
    }

    // Remove ponto decimal isolado no final
    if (_display.endsWith('.')) {
      _display = _display.substring(0, _display.length - 1);
    }

    // Remove zeros desnecessários após o ponto decimal
    if (_display.contains('.')) {
      _display = _display.replaceAll(RegExp(r'\.?0+$'), '');
    }

    // Remove '.0' do final, se presente
    if (_display.endsWith('.0')) {
      _display = _display.substring(0, _display.length - 2);
    }
  }

  // Função para calcular a raiz quadrada
  void _calculateSqrt() {
    if (_currentNumber.isNotEmpty) {
      try {
        Decimal number = Decimal.parse(_currentNumber);

        // Verificar se o número é negativo
        if (number < Decimal.zero) {
          _display = 'Erro: Número negativo';
          return;
        }

        // Calcular a raiz quadrada usando o método de Newton-Raphson
        Decimal sqrtResult = _sqrtNewtonRaphson(number, _decimalPlaces);

        _result = sqrtResult;

        // Atualizar o display
        _currentNumber = _result.toStringAsFixed(_decimalPlaces);
        _isResultDisplayed = true; // Define o flag como verdadeiro
        _updateDisplay();
      } catch (e) {
        _display = 'Erro';
      }
    }
  }

  Decimal _sqrtNewtonRaphson(Decimal value, int decimalPlaces) {
    if (value < Decimal.zero) {
      throw ArgumentError('Cannot compute square root of a negative number');
    } else if (value == Decimal.zero) {
      return Decimal.zero;
    }

    Decimal two = Decimal.fromInt(2);
    Decimal guess =
        (value / two).toDecimal(scaleOnInfinitePrecision: decimalPlaces);
    Decimal lastGuess;

    int maxIterations = 750;
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

      // Verificar se a diferença entre as suposições é menor que a precisão desejada
      Decimal difference = (guess - lastGuess).abs();
      Decimal epsilon = Decimal.parse('1e-${decimalPlaces + 1}');
      if (difference < epsilon) {
        break;
      }
    }

    // Arredondar o resultado para o número de casas decimais desejado
    return Decimal.parse(guess.toStringAsFixed(decimalPlaces));
  }

  // Função para inserir o valor de Pi
  void _insertPi() {
    // Definindo Pi com alta precisão
    final Decimal piDecimal =
        Decimal.parse('3.14159265358979323846264338327950288419716939937510582097494459230');

    if (_currentNumber.isEmpty) {
      _currentNumber = piDecimal.toStringAsFixed(_decimalPlaces);
    } else {
      _currentNumber += piDecimal.toStringAsFixed(_decimalPlaces);
    }
  }

  // Função para calcular o inverso (1/x)
  void _calculateInverse() {
    if (_currentNumber.isNotEmpty) {
      try {
        Decimal number = Decimal.parse(_currentNumber);
        if (number != Decimal.zero) {
          _result = (Decimal.one / number)
              .toDecimal(scaleOnInfinitePrecision: _decimalPlaces);
          _currentNumber = _result.toStringAsFixed(_decimalPlaces);
          _isResultDisplayed = true; // Define o flag como verdadeiro
          _updateDisplay();
        } else {
          _display = 'Erro: Divisão por zero';
        }
      } catch (e) {
        _display = 'Erro';
      }
    }
  }

  void _calculateFactorial() {
    if (_currentNumber.isNotEmpty) {
      try {
        Decimal numberDecimal = Decimal.parse(_currentNumber);

        // Verificar se o número é inteiro
        if ((numberDecimal % Decimal.one) != Decimal.zero) {
          _display = 'Erro: Entrada não é um inteiro';
          return;
        }

        // Converter para BigInt
        BigInt number = numberDecimal.toBigInt();

        // Verificar se o número é não negativo
        if (number >= BigInt.zero) {
          BigInt factorialResult = _factorial(number);
          _result = Decimal.fromBigInt(factorialResult);
          _currentNumber = _result.toString(); // Fatorial é inteiro
          _isResultDisplayed = true; // Define o flag como verdadeiro
          _updateDisplay();
        } else {
          _display = 'Erro: Número negativo';
        }
      } catch (e) {
        _display = 'Erro: Entrada inválida';
      }
    }
  }

  // Método para calcular o fatorial usando BigInt
  BigInt _factorial(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError('Número negativo não permitido');
    BigInt result = BigInt.one;
    for (BigInt i = BigInt.one; i <= n; i = i + BigInt.one) {
      result *= i;
    }
    return result;
  }

  // Função para remover o último dígito inserido
  void _backspace() {
    if (_currentNumber.isNotEmpty) {
      if (_currentNumber.endsWith('.')) {
        _hasDecimal = false;
      }
      _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
    }
    _updateDisplay();
  }

  // Função para calcular a potência de um Decimal elevado a um expoente inteiro
  Decimal _powDecimal(Decimal base, int exponent) {
    return base
        .pow(exponent)
        .toDecimal(scaleOnInfinitePrecision: _decimalPlaces);
  }
}
