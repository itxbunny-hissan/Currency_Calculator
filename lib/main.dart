import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'currency_service.dart';
import 'history_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ConverterScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3B7E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.currency_exchange, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text("Global Currency",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});
  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final CurrencyService _service = CurrencyService();
  final TextEditingController _amountController = TextEditingController(text: "1");

  String _fromCurrency = 'USD';
  String _toCurrency = 'PKR';
  double _result = 0.0;
  double _currentRate = 0.0;
  bool _isLoading = false;
  List<String> _allCurrencies = ['USD', 'PKR', 'EUR', 'GBP', 'INR', 'SAR', 'AED', 'JPY'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final rates = await _service.fetchRates(_fromCurrency);
    if (rates.isNotEmpty) {
      setState(() {
        _allCurrencies = rates.keys.toList()..sort();
      });
      await _convert();
    }
  }

  Future<void> _convert() async {
    final input = _amountController.text.trim();
    if (input.isEmpty) {
      setState(() => _result = 0.0);
      return;
    }

    final double amount = double.tryParse(input) ?? 0.0;
    
    // Start Loading for calculation
    setState(() => _isLoading = true);

    // Inside _convert() in ConverterScreenState
try {
  final rates = await _service.fetchRates(_fromCurrency);
  if (rates.isNotEmpty && rates.containsKey(_toCurrency)) { // Check if PKR exists
    final double rate = (rates[_toCurrency] as num).toDouble();
    setState(() {
      _currentRate = rate;
      _result = amount * rate;
      _isLoading = false;
    });
  } else {
     // If the API fails, don't show 1.0, show an error
     setState(() => _isLoading = false);
  }
} catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E3B7E);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: primaryColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Global Currency",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              Text("Live Exchange Rate",
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40))),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildConversionCard(primaryColor),
            _buildInfoTile(primaryColor),
            _buildActionButtons(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionCard(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(border: InputBorder.none, hintText: "Enter Amount"),
            onChanged: (_) => _convert(),
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(child: _buildCurrencySelector(_fromCurrency, (v) => setState(() => _fromCurrency = v!))),
              IconButton(
                icon: const Icon(Icons.swap_horiz, color: Colors.grey, size: 30),
                onPressed: () {
                  setState(() {
                    final temp = _fromCurrency;
                    _fromCurrency = _toCurrency;
                    _toCurrency = temp;
                  });
                  _convert();
                },
              ),
              Expanded(child: _buildCurrencySelector(_toCurrency, (v) => setState(() => _toCurrency = v!))),
            ],
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                Text(
                  "${CurrencyService.getSymbol(_toCurrency)} ${_result.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 5),
                Text(
                  "1 $_fromCurrency = ${_currentRate.toStringAsFixed(4)} $_toCurrency",
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 15),
            Expanded(
              child: Text("Rates are provided by real-time market data providers.",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: const Icon(Icons.auto_graph),
        label: Text("VIEW 30-DAY TRENDS",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HistoryScreen(from: _fromCurrency, to: _toCurrency)));
        },
      ),
    );
  }

  Widget _buildCurrencySelector(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _allCurrencies.contains(value) ? value : _allCurrencies.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: _allCurrencies.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text("${CurrencyService.getFlag(code)} $code",
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (val) {
            onChanged(val);
            _convert();
          },
        ),
      ),
    );
  }
}