import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrenciesPage extends StatefulWidget {
  @override
  _CurrenciesPageState createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends State<CurrenciesPage> {
  List<Map<String, dynamic>> _currencies = [];
  bool _isLoading = true;
  final _currencyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
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

  // Добавление новой валюты
  Future<void> _addCurrency(String name) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/add-currency/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Currency added successfully!")),
        );
        _currencyNameController.clear();
        await _fetchCurrencies();// Обновляем список валют
      } else {
        final error = json.decode(response.body)['errors'] ?? 'Failed to add currency.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }



  // Функция для удаления валюты
Future<void> _deleteCurrency(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/currencies/$id/'),
    );

    if (response.statusCode == 204) {
      setState(() {
        _currencies.removeWhere((currency) => currency['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Currency deleted successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete currency.")),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $error")),
    );
  }
}

// Обновленный список валют с кнопкой удаления
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Currencies"),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _currencyNameController,
                  decoration: InputDecoration(labelText: "Currency Name"),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final currencyName = _currencyNameController.text.trim();
                  if (currencyName.isNotEmpty) {
                    _addCurrency(currencyName);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Currency name cannot be empty.")),
                    );
                  }
                },
                child: Text("Add"),
              ),
            ],
          ),
        ),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView.builder(
                  itemCount: _currencies.length,
                  itemBuilder: (context, index) {
                    final currency = _currencies[index];
                    return ListTile(
                      title: Text(currency['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteCurrency(currency['id']);
                        },
                      ),
                    );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
