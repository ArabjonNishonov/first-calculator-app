import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculatroni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101216),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7657),
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _display = '0';
  bool _justCalculated = false;

  static const _buttons = [
    ['AC', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  void _press(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _display = '0';
        _justCalculated = false;
      } else if (value == '⌫') {
        if (_justCalculated) {
          _expression = '';
          _display = '0';
          _justCalculated = false;
        } else if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
        }
      } else if (value == '=') {
        if (_expression.isEmpty) return;
        try {
          _display = _format(_evaluate(_expression));
          _expression = _display;
          _justCalculated = true;
        } catch (_) {
          _display = 'Error';
          _expression = '';
        }
      } else if (value == '±') {
        if (_expression.isNotEmpty && double.tryParse(_expression) != null) {
          _expression = _expression.startsWith('-')
              ? _expression.substring(1)
              : '-$_expression';
          _display = _expression;
        }
      } else {
        if (_justCalculated && _isDigit(value)) _expression = '';
        _justCalculated = false;
        if (value == '%' && _expression.isNotEmpty) {
          final number = double.tryParse(_expression);
          if (number != null) {
            _expression = _format(number / 100);
            _display = _expression;
          }
        } else if (_isOperator(value)) {
          if (_expression.isNotEmpty &&
              !_isOperator(_expression[_expression.length - 1])) {
            _expression += value;
          }
        } else if (value != '.' || !_currentNumberHasDot) {
          _expression += value;
          _display = _expression;
        }
      }
    });
  }

  bool get _currentNumberHasDot =>
      _expression.split(RegExp(r'[+−×÷]')).last.contains('.');

  bool _isDigit(String value) => RegExp(r'^[0-9.]$').hasMatch(value);

  bool _isOperator(String value) => ['+', '−', '×', '÷'].contains(value);

  double _evaluate(String input) {
    final tokens = RegExp(r'(?<=[+−×÷])|(?=[+−×÷])')
        .split(input)
        .where((token) => token.isNotEmpty)
        .toList();
    final numbers = <double>[];
    final operators = <String>[];
    int precedence(String op) => op == '+' || op == '−' ? 1 : 2;

    void calculate() {
      final right = numbers.removeLast();
      final left = numbers.removeLast();
      final op = operators.removeLast();
      numbers.add(switch (op) {
        '+' => left + right,
        '−' => left - right,
        '×' => left * right,
        '÷' => right == 0 ? double.nan : left / right,
        _ => throw const FormatException(),
      });
    }

    for (final token in tokens) {
      final number = double.tryParse(token);
      if (number != null) {
        numbers.add(number);
      } else if (_isOperator(token)) {
        while (operators.isNotEmpty &&
            precedence(operators.last) >= precedence(token)) {
          calculate();
        }
        operators.add(token);
      } else {
        throw const FormatException();
      }
    }
    while (operators.isNotEmpty) {
      if (numbers.length < 2) throw const FormatException();
      calculate();
    }
    if (numbers.length != 1 || numbers.single.isNaN || numbers.single.isInfinite) {
      throw const FormatException();
    }
    return numbers.single;
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(math.min(8, 12))
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'CALCULATRONI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        color: Color(0xFFFF7657),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz_rounded, color: Colors.white54),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _display,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ..._buttons.map(
                (row) => Expanded(
                  child: Row(children: row.map(_buildButton).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label) {
    final isOperator = _isOperator(label) || label == '=';
    final isAction = ['AC', '⌫', '%', '±'].contains(label);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: isOperator
              ? const Color(0xFFFF7657)
              : isAction
                  ? const Color(0xFF272A31)
                  : const Color(0xFF1A1D22),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _press(label),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: label == 'AC' ? 17 : 25,
                  fontWeight: FontWeight.w500,
                  color: isOperator
                      ? Colors.white
                      : isAction
                          ? const Color(0xFFFFA08B)
                          : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
