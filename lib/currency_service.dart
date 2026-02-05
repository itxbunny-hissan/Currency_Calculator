import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Using a more comprehensive API for better accuracy with PKR/INR
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  static const Map<String, String> flags = {
   'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧', 'JPY': '🇯🇵',
    'AUD': '🇦🇺', 'CAD': '🇨🇦', 'CHF': '🇨🇭', 'CNY': '🇨🇳',
    'PKR': '🇵🇰', 'INR': '🇮🇳', 'BDT': '🇧🇩', 'KRW': '🇰🇷',
    'IDR': '🇮🇩', 'ILS': '🇮🇱', 'ISK': '🇮🇸', 'MXN': '🇲🇽',
    'MYR': '🇲🇾', 'NOK': '🇳🇴', 'NZD': '🇳🇿', 'PHP': '🇵🇭',
    'PLN': '🇵🇱', 'RON': '🇷🇴', 'SEK': '🇸🇪', 'SGD': '🇸🇬',
    'THB': '🇹🇭', 'DKK': '🇩🇰', 'AED': '🇦🇪', 'SAR': '🇸🇦', 
    'QAR': '🇶🇦', 'ZAR': '🇿🇦', 'EGP': '🇪🇬', 'BRL': '🇧🇷',
  };

  static const Map<String, String> symbols = {
    'USD': r'$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
    'PKR': 'Rs', 'INR': '₹', 'SAR': '﷼', 'AED': 'د.إ',
  };

  static String getFlag(String code) => flags[code.toUpperCase()] ?? '🌍';
  static String getSymbol(String code) => symbols[code.toUpperCase()] ?? code;

  // Real-time Fetching
  Future<Map<String, dynamic>> fetchRates(String base) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$base'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates'] as Map<String, dynamic>;
      }
    } catch (e) {
      print("API Error: $e");
    }
    return {};
  }

  // Accurate Calculation
  double convert({required double amount, required double rate}) {
    return amount * rate;
  }

  // Fetch History (Simplified for this version)
  Future<Map<DateTime, double>> fetchHistory(String from, String to) async {
    // Note: Most free APIs require a key for history. 
    // This is a placeholder that returns dummy data to keep the chart working.
    return {
      DateTime.now().subtract(const Duration(days: 3)): 278.5,
      DateTime.now().subtract(const Duration(days: 2)): 279.1,
      DateTime.now().subtract(const Duration(days: 1)): 278.2,
      DateTime.now(): 278.8,
    };
  }
}