import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _currencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _fetchCurrencies();
  }

  // Получение списка отчетов
  Future<void> _fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/reports/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reports = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch reports.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  // Получение списка валют
  Future<void> _fetchCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/currencies/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currencies = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch currencies.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  // Функция для получения названия валюты по ID
  String _getCurrencyName(int id) {
    final currency = _currencies.firstWhere((currency) => currency['id'] == id, orElse: () => {'name': 'Unknown'});
    return currency['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return Card(
                        child: ListTile(
                          title: Text("Currency: ${_getCurrencyName(report['currency'])}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Bought: ${report['total_bought']}"),
                              Text("Total Spent on Buy: ${report['total_spent_on_buy']}"),
                              Text("Total Sold: ${report['total_sold']}"),
                              Text("Total Earned on Sell: ${report['total_earned_on_sell']}"),
                              Text("Net Profit: ${report['net_profit']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Total Som: ${_calculateTotalSom()}"),
                      Text("Net Profit: ${_calculateNetProfit()}"),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Функция для подсчета общего количества Som (можно использовать общую логику подсчета из данных)
  String _calculateTotalSom() {
    double totalSom = 0.0;
    for (var report in _reports) {
      totalSom += double.tryParse(report['total_bought']) ?? 0.0;
    }
    return totalSom.toStringAsFixed(2);
  }

  // Функция для подсчета общего профита
  String _calculateNetProfit() {
    double netProfit = 0.0;
    for (var report in _reports) {
      netProfit += double.tryParse(report['net_profit']) ?? 0.0;
    }
    return netProfit.toStringAsFixed(2);
  }
}
