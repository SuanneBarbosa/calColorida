import 'dart:math';

class CalculatorController {
  String _display = '0';
  String _currentNumber = '';
  String _operation = '';
  double _result = 0;
  bool _hasDecimal = false;
  String _expression = '';

  String get display => _display;
  String get expression => _expression;

  void processKey(String key) {
    // Zerar a calculadora se já houver um resultado e um novo número for pressionado
    if (_operation.isEmpty && _display == _result.toString() &&
        (key != 'C' &&
            key != '=' &&
            !['+', '-', 'x', '/', '^', '√', 'π', '1/x', '!', '<-']
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
      _backspace();
      _expression = _expression.substring(0, _expression.length - 1);
    } else { //  Adiciona um novo dígito ao número atual
      // Se uma operação foi concluída, reinicia o _currentNumber
      if (_operation.isEmpty) {
        _currentNumber = key; 
      } else {
        _currentNumber += key;
      }
      _expression += key; // Adiciona o dígito à expressão
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
    _currentNumber = _result.toString(); 
    _operation = ''; // Limpa a operação após o cálculo
    _expression = ''; // Limpa a expressão após o cálculo
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

  void _addDecimal() {
    if (!_hasDecimal) {
      _currentNumber += _currentNumber.isEmpty ? '0.' : '.';
      _hasDecimal = true;
    }
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

  void _updateDisplay() {
    _display = _currentNumber.isEmpty ? _result.toString() : _currentNumber;
    if (_display.endsWith('.0')) {
      _display = _display.substring(0, _display.length - 2);
    }
  }

  void _calculateSqrt() {
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

  void _insertPi() {
    if (_currentNumber.isEmpty) {
      _currentNumber = pi.toString();
    } else {
      _currentNumber += pi.toString();
    }
  }

  void _calculateInverse() {
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

  void _calculateFactorial() {
    if (_currentNumber.isNotEmpty) {
      try {
        double number = double.parse(_currentNumber);
        if (number >= 0 && number <= 20) {
          _result = _factorial(number.toInt()).toDouble();
          _currentNumber = _result.toString();
        } else if (number == 0) {
          _result = 1;
          _currentNumber = _result.toString();
        } else {
          _display = 'Erro: Número inválido para fatorial';
        }
      } catch (e) {
        _display = 'Erro';
      }
    }
  }

  int _factorial(int n) {
    if (n == 0) return 1;
    return n * _factorial(n - 1);
  }

  void _backspace() {
    if (_currentNumber.isNotEmpty) {
      _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
    }
    _updateDisplay();
  }
}