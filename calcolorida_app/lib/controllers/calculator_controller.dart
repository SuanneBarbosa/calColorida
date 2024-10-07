import 'dart:math';

import 'package:flutter/material.dart';


class CalculatorController {
  String _display = '0';
  String _currentNumber = '';
  String _operation = '';
  double _result = 0;
  bool _hasDecimal = false;
  String _expression = '';
  int _decimalPlaces = 2; // Número padrão de casas decimais
  
  

  String get display => _display;
  String get expression => _expression;

  void processKey(String key) {
    // Zerar a calculadora se já houver um resultado e um novo número for pressionado
    if (_operation.isEmpty &&
        _display == _result.toString() &&
        (key != 'C' &&
            key != '=' &&
            !['+', '-', 'x', '/', '^', '√', 'π', '1/x', '!', '<-', 'S']
                .contains(key))) {
      _clear();
    }

    if (key == 'C') {
      _clear();
    } else if (key == '=') {
      _calculate();
    } else if (['+', '-', 'x', '/', '^'].contains(key)) {
      _setOperation(key);
      _expression += ' $key ';
    } else if (key == '.') {
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
      if (_currentNumber.isEmpty) { 
        // Se _currentNumber estiver vazio (resultado), ignora backspace
      } else {
        _backspace();
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      }
    } else {
      // Adiciona um novo dígito ao número atual
      if (_operation.isEmpty) {
        _currentNumber += key;
      } else {
        _currentNumber += key;
      }
      _expression += key;
    }
    _updateDisplay();
  }

  void _clear() {
    _currentNumber = '';
    _operation = '';
    _result = 0;
    _hasDecimal = false;
    _expression = '';
    _display = '0';
  }

  void _calculate() {
    if (_operation.isEmpty) return;
    double secondNumber = double.parse(_currentNumber);
    switch (_operation) {
      case '+':
        _result += secondNumber;
        break;
      case '-':
        _result -= secondNumber;
        break;
      case 'x':
        _result *= secondNumber;
        break;
      case '/':
        if (secondNumber != 0) {
          _result /= secondNumber;
        } else {
          _display = 'Erro';
          return;
        }
        break;
      case '^':
        _result = (pow(_result, secondNumber)).toDouble();
        break;
    }
    // _currentNumber = _result.toString();
    // Aplicar o número de casas decimais apenas no resultado final
    _currentNumber = _result.toStringAsFixed(_decimalPlaces);
    _operation = ''; // Limpa a operação após o cálculo
    _expression = ''; // Limpa a expressão após o cálculo
    _updateDisplay(); // Atualiza o display com o resultado formatado
  }

  void _setOperation(String op) {
    // Se houver um número atual, processa a operação
    if (_currentNumber.isNotEmpty) {
      if (_operation.isNotEmpty) {
        _calculate();
      } else {
        // Se não houver operação, o _currentNumber é o primeiro número
        try {
          _result = double.parse(_currentNumber);
        } catch (e) {
          _display = 'Erro';
          return;
        }
      }
      // Define a nova operação
      _operation = op;
      _currentNumber = ''; // Reinicia o número atual para a próxima entrada
      _hasDecimal = false;
    }
  }

  // void _addDecimal() {
  //   if (!_hasDecimal) {
  //     _currentNumber += _currentNumber.isEmpty ? '0.' : '.';
  //     _hasDecimal = true;
  //   }
  // }
  void _addDecimal() {
    if (!_hasDecimal) {
      _currentNumber += '.';
      _hasDecimal = true;
    }
  }

  void _applyDecimalPlaces() {
    // Verifica se o número de casas decimais é válido
    if (_decimalPlaces < 0) {
      _decimalPlaces = 0;
    }

    // Atualiza o display para refletir a nova quantidade de casas decimais
    _updateDisplay();
  }

  void _addDigit(String digit) {
    if (_operation.isEmpty && _display == _result.toString()) {
      _currentNumber = digit; // Reinicia _currentNumber
    } else {
      // Verifica se o primeiro dígito é zero ou se é um ponto decimal
      if ((_currentNumber == '0' && digit != '.') ||
          (_currentNumber.isEmpty && digit == '.')) {
        _currentNumber = digit;
      } else {
        _currentNumber += digit;
      }
    }
  }

  void setDecimalPlaces(int decimalPlaces) {////////////////////////////////
    if (decimalPlaces >= 0) {
      _decimalPlaces = decimalPlaces;
    }
  }

  void _updateDisplay() {////////////////////////////////////////////////////////////
    // Mostra o resultado formatado com o número correto de casas decimais
  if (_currentNumber.isEmpty) {
    _display = _result.toStringAsFixed(_decimalPlaces);
  } else {
    _display = _currentNumber;
  }

    // Verifica se o display termina com um ponto decimal isolado e remove-o
    if (_display.endsWith('.')) {
      _display = _display.substring(0, _display.length - 1);
    }

    // Formatar o número para remover zeros desnecessários
    if (_display.contains('.')) {
      _display = _display.replaceAll(RegExp(r'\.?0+$'), '');
    }

    // Remove ".0" do final, se necessário
    if (_display.endsWith('.0')) {
      _display = _display.substring(0, _display.length - 2);
    }
  }

  void _calculateSqrt() { //////////////////////////////////////////////////
    if (_currentNumber.isNotEmpty) {
      try {
        double number = double.parse(_currentNumber);
        _result = sqrt(number);
        _currentNumber = _result.toString();
      } catch (e) {
        _display = 'Erro';
      }
    }
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

  // Widget _buildMosaic(String result) {
  //   // ... (código do mosaico)
  // }

  void _insertPi() {
    if (_currentNumber.isEmpty) {
      _currentNumber = pi.toString();
    } else {
      _currentNumber += pi.toString();
    }
  }

  void _calculateInverse() { //////////////////////////////////////
    if (_currentNumber.isNotEmpty) {
      try {
        double number = double.parse(_currentNumber);
        if (number != 0) {
          _result = 1 / number;
          _currentNumber = _result.toString();
        } else {
          _display = 'Erro: Divisão por zero';
        }
      } catch (e) {
        _display = 'Erro';
      }
    }
  }

  // void _calculateFactorial() {
  //   if (_currentNumber.isNotEmpty) {
  //     try {
  //       double number = double.parse(_currentNumber);
  //       if (number >= 0 && number <= 20) {
  //         _result = _factorial(number.toInt()).toDouble();
  //         _currentNumber = _result.toString();
  //       } else if (number == 0) {
  //         _result = 1;
  //         _currentNumber = _result.toString();
  //       } else {
  //         _display = 'Erro: Número inválido para fatorial';
  //       }
  //     } catch (e) {
  //       _display = 'Erro';
  //     }
  //   }
  // }

  void _calculateFactorial() {
    if (_currentNumber.isNotEmpty) {
      try {
        int number = int.parse(_currentNumber);
        if (number >= 0) {
          _result = _factorial(number).toDouble();
          _currentNumber = _result.toString();
        } else {
          _display = 'Erro: Número negativo';
        }
      } catch (e) {
        _display = 'Erro: Entrada inválida';
      }
    }
  }

  int _factorial(int n) {
    if (n == 0) return 1;
    return n * _factorial(n - 1);
  }

  void _backspace() {
    if (_currentNumber.isNotEmpty) {
      // Verifica se o último caractere é um ponto decimal
      if (_currentNumber.endsWith('.')) {
        _hasDecimal = false; // Se for, ajusta a flag de ponto decimal
      }
      _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
    }

    // Garante que o display seja atualizado
    _updateDisplay();
  }
}
