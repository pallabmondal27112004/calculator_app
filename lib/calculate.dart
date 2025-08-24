class CalculatorEngine {
  static double add(double a, double b) => a + b;
  static double subtract(double a, double b) => a - b;
  static double multiply(double a, double b) => a * b;
  static double divide(double a, double b) {
    if (b == 0) return double.infinity;
    return a / b;
  }
  static double modulo(double a, double b) => a % b;
  
  static double percentage(double value) => value / 100;
  
  static bool isValidNumber(String input) {
    return double.tryParse(input) != null;
  }
  
  static String formatNumber(double number) {
    if (number == double.infinity || number == double.negativeInfinity) {
      return 'Error';
    }
    if (number.isNaN) {
      return 'Error';
    }
    
    // Remove unnecessary decimal places
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    } else {
      // Limit to 8 decimal places to prevent overflow
      String formatted = number.toStringAsFixed(8);
      // Remove trailing zeros
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }
  }
}
