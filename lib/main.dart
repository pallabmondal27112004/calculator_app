import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorUI(),
    );
  }
}

class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  String display = '0'; // The number currently displayed
  String history = ''; // The full calculation history
  double num1 = 0;
  double num2 = 0;
  String operator = '';
  bool newCalculation = true;
  bool hasError = false;
  void onButtonPressed(String buttonText) {
    setState(() {
      // Reset error state on any button press except AC
      if (hasError && buttonText != 'AC') {
        _clearAll();
      }

      if (buttonText == 'AC') {
        _clearAll();
      } else if (['+', '-', '×', '÷', '%'].contains(buttonText)) {
        _handleOperator(buttonText);
      } else if (buttonText == '=') {
        _handleEquals();
      } else if (buttonText == '+/-') {
        _handlePlusMinus();
      } else if (buttonText == '.') {
        _handleDecimal();
      } else {
        _handleNumber(buttonText);
      }
    });
  }

  void _clearAll() {
    display = '0';
    history = '';
    num1 = 0;
    num2 = 0;
    operator = '';
    newCalculation = true;
    hasError = false;
  }

  void _handleOperator(String op) {
    if (hasError) return;

    if (operator.isNotEmpty && !newCalculation) {
      // Perform the previous operation first
      if (_isValidNumber(display)) {
        num2 = double.parse(display);
        double result = _performCalculation(num1, num2, operator);
        if (_isError(result)) {
          _setError();
          return;
        }
        display = _formatResult(result);
        num1 = result;
      }
    } else {
      if (_isValidNumber(display)) {
        num1 = double.parse(display);
      }
    }

    history = '${_formatResult(num1)} $op';
    operator = op;
    newCalculation = true;
  }

  void _handleEquals() {
    if (hasError || operator.isEmpty || newCalculation) return;

    if (_isValidNumber(display)) {
      num2 = double.parse(display);
      history += ' ${_formatResult(num2)} =';
      double result = _performCalculation(num1, num2, operator);

      if (_isError(result)) {
        _setError();
        return;
      }

      display = _formatResult(result);
      num1 = result;
      num2 = 0;
      operator = '';
      newCalculation = true;
    }
  }

  void _handlePlusMinus() {
    if (hasError) return;

    if (display != '0' && _isValidNumber(display)) {
      double value = double.parse(display);
      display = _formatResult(value * -1);
    }
  }

  void _handleDecimal() {
    if (hasError) return;

    if (newCalculation) {
      display = '0.';
      newCalculation = false;
    } else if (!display.contains('.')) {
      display += '.';
    }
  }

  void _handleNumber(String number) {
    if (hasError) return;

    if (display == '0' || newCalculation) {
      display = number;
      newCalculation = false;
    } else {
      // Prevent display from getting too long
      if (display.length < 10) {
        display += number;
      }
    }
  }

  bool _isValidNumber(String input) {
    return double.tryParse(input) != null;
  }

  bool _isError(double result) {
    return result == double.infinity ||
        result == double.negativeInfinity ||
        result.isNaN;
  }

  void _setError() {
    display = 'Error';
    history = '';
    hasError = true;
  }

  double _performCalculation(double num1, double num2, String operator) {
    switch (operator) {
      case '+':
        return num1 + num2;
      case '-':
        return num1 - num2;
      case '×':
        return num1 * num2;
      case '÷':
        if (num2 == 0) {
          return double.infinity;
        }
        return num1 / num2;
      case '%':
        return num1 % num2;
      default:
        return num2;
    }
  }

  String _formatResult(double result) {
    if (result == double.infinity || result == double.negativeInfinity) {
      return 'Error';
    }
    if (result.isNaN) {
      return 'Error';
    }

    // Remove unnecessary decimal places
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    } else {
      // Limit to 8 decimal places to prevent overflow
      String formatted = result.toStringAsFixed(8);
      // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2A33), Color(0xFF1A1A21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Display Area with Glassmorphism
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              history,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white54,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                display,
                                style: const TextStyle(
                                  fontSize: 56,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Button Grid
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildButtonRow(
                      ['AC', '+/-', '%', '÷'],
                      const [
                        Color(0xFFD4D4D2), // AC, +/-, %
                        Color(0xFFD4D4D2),
                        Color(0xFFD4D4D2),
                        Color(0xFFFE9F0E), // Operator
                      ],
                    ),
                    buildButtonRow(
                      ['7', '8', '9', '×'],
                      const [
                        Color(0xFF505050), // Numbers
                        Color(0xFF505050),
                        Color(0xFF505050),
                        Color(0xFFFE9F0E), // Operator
                      ],
                    ),
                    buildButtonRow(
                      ['4', '5', '6', '-'],
                      const [
                        Color(0xFF505050),
                        Color(0xFF505050),
                        Color(0xFF505050),
                        Color(0xFFFE9F0E),
                      ],
                    ),
                    buildButtonRow(
                      ['1', '2', '3', '+'],
                      const [
                        Color(0xFF505050),
                        Color(0xFF505050),
                        Color(0xFF505050),
                        Color(0xFFFE9F0E),
                      ],
                    ),
                    buildButtonRow(
                      ['0', '.', '='],
                      const [
                        Color(0xFF505050),
                        Color(0xFF505050),
                        // Colors.transparent, // Empty space for the button
                        Color(0xFFFE9F0E),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtonRow(List<String> labels, List<Color> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: List.generate(labels.length, (index) {
          bool isWide = labels[index] == '0';
          bool isOperator = ['÷', '×', '-', '+', '='].contains(labels[index]);
          bool isUtility = ['AC', '+/-', '%'].contains(labels[index]);

          return Expanded(
            flex: isWide ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  labels[index].isNotEmpty
                      ? ElevatedButton(
                        onPressed: () => onButtonPressed(labels[index]),
                        style: ElevatedButton.styleFrom(
                          shape:
                              isWide
                                  ? const StadiumBorder()
                                  : const CircleBorder(),
                          backgroundColor: colors[index],
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 5,
                        ),
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: isWide ? 32 : 28,
                            fontWeight:
                                isOperator || isUtility
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                            color: isUtility ? Colors.black : Colors.white,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          );
        }),
      ),
    );
  }
}
