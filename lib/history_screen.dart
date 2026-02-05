import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'currency_service.dart';

class HistoryScreen extends StatelessWidget {
  final String from;
  final String to;
  final _service = CurrencyService();

  HistoryScreen({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E3B7E);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: Text('$from to $to Trend', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<DateTime, double>>(
        future: _service.fetchHistory(from, to),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState();
          }

          final history = snapshot.data!;
          final List<FlSpot> spots = [];
          
          // Sort dates to ensure the line flows left to right
          var sortedDates = history.keys.toList()..sort();
          for (int i = 0; i < sortedDates.length; i++) {
            spots.add(FlSpot(i.toDouble(), history[sortedDates[i]]!));
          }

          double lastPrice = spots.last.y;
          double firstPrice = spots.first.y;
          double percentChange = ((lastPrice - firstPrice) / firstPrice) * 100;
          bool isUp = percentChange >= 0;

          return Column(
            children: [
              // 1. High-Performance Header (Google Style)
              _buildHeader(from, to, lastPrice, percentChange, isUp, primaryColor),
              
              const SizedBox(height: 20),

              // 2. The Interactive Chart
              _buildChartCard(spots, primaryColor, isUp),

              // 3. Low/High Stats
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    _buildStatTile("30D LOW", spots.map((s) => s.y).reduce((a, b) => a < b ? a : b), Colors.red),
                    const SizedBox(width: 15),
                    _buildStatTile("30D HIGH", spots.map((s) => s.y).reduce((a, b) => a > b ? a : b), Colors.green),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String from, String to, double price, double change, bool isUp, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current Rate", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price.toStringAsFixed(4), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(to, style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUp ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${isUp ? "▲" : "▼"} ${change.abs().toStringAsFixed(2)}% (Past 30 Days)",
              style: TextStyle(color: isUp ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<FlSpot> spots, Color primary, bool isUp) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(5, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => primary,
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(s.y.toStringAsFixed(4), const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: isUp ? Colors.green : Colors.red,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    (isUp ? Colors.green : Colors.red).withOpacity(0.3),
                    (isUp ? Colors.green : Colors.red).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("History data currently unavailable", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}