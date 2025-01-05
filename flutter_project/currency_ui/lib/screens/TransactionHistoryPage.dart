import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _currencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Получение транзакций и валют
  Future<void> _fetchData() async {
    try {
      final transactions = await _fetchTransactions();
      final currencies = await _fetchCurrencies();

      setState(() {
        _transactions = transactions;
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  // Получение списка транзакций
  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/transactions/'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch transactions.");
    }
  }

  // Получение списка валют
  Future<List<Map<String, dynamic>>> _fetchCurrencies() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/currencies/'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch currencies.");
    }
  }

  // Получение названия валюты по её ID
  String _getCurrencyName(int currencyId) {
    final currency = _currencies.firstWhere(
      (currency) => currency['id'] == currencyId,
      orElse: () => {'name': 'Unknown'},
    );
    return currency['name'];
  }

  // Удаление транзакции
  Future<void> _deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/transactions/$id/'),
      );

      if (response.statusCode == 204) {
        setState(() {
          _transactions.removeWhere((transaction) => transaction['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete transaction.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  // Функция для обновления транзакции
  Future<void> _updateTransaction(int id, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('http://127.0.0.1:8000/api/transactions/$id/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction updated successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update transaction.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Transaction History")),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return Card(
                child: ListTile(
                  title: Text("Type: ${transaction['type']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Currency: ${_getCurrencyName(transaction['currency'])}"),
                      Text("Quantity: ${transaction['quantity']}"),
                      Text("Rate: ${transaction['rate']}"),
                      Text("Total: ${transaction['total']}"),
                      Text("Timestamp: ${_formatTimestamp(transaction['timestamp'])}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final updatedData = await _showEditDialog(transaction);
                          if (updatedData != null) {
                            await _updateTransaction(transaction['id'], updatedData);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTransaction(transaction['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
  );
}

// Форматирование timestamp в удобный формат
String _formatTimestamp(String timestamp) {
  try {
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
           "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    return "Invalid date";
  }
}

  // Диалог для редактирования транзакции
  Future<Map<String, dynamic>?> _showEditDialog(Map<String, dynamic> transaction) {
    final _typeController = TextEditingController(text: transaction['type']);
    final _quantityController = TextEditingController(text: transaction['quantity'].toString());
    final _rateController = TextEditingController(text: transaction['rate'].toString());

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: "Type"),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _rateController,
                decoration: InputDecoration(labelText: "Rate"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'type': _typeController.text,
                  'quantity': double.tryParse(_quantityController.text) ?? 0,
                  'rate': double.tryParse(_rateController.text) ?? 0,
                });
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
