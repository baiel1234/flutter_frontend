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
        Uri.parse('https://baiel123.pythonanywhere.com/api/reports/'),
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
        Uri.parse('https://baiel123.pythonanywhere.com/api/currencies/'),
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
      title: Text("Report", style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blueAccent,
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // List of Reports
              Expanded(
                child: ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          "Currency: ${_getCurrencyName(report['currency'])}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text("Total Bought: ${report['total_bought']}"),
                            SizedBox(height: 4),
                            Text("Total Spent on Buy: ${report['total_spent_on_buy']}"),
                            SizedBox(height: 4),
                            Text("Total Sold: ${report['total_sold']}"),
                            SizedBox(height: 4),
                            Text("Total Earned on Sell: ${report['total_earned_on_sell']}"),
                            SizedBox(height: 4),
                            Text("Net Profit: ${report['net_profit']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Summary Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Som: ${_calculateTotalSom()}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Net Profit: ${_calculateNetProfit()}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}

  // Функция для подсчета общего количества Som
  String _calculateTotalSom() {
    double totalSom = 0.0;

    // Ищем валюту Som в списке валют
    final somCurrency = _currencies.firstWhere(
      (currency) => currency['name'].toLowerCase() == 'som',
      orElse: () => {},  // Return an empty map if not found
    );

    if (somCurrency.isNotEmpty) {
      // Если валюта Som найдена, то получаем ее количество
      totalSom = double.tryParse(somCurrency['quantity'].toString()) ?? 0.0;
    }

    // Возвращаем количество Som с точностью до 2 знаков
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
