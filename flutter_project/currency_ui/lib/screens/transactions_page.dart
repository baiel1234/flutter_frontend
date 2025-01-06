import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:currency_ui/screens/TransactionHistoryPage.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  String? _selectedType = 'sell';
  int? _selectedCurrencyId; // ID выбранной валюты
  bool _isLoading = false;
  double? _total;

  List<Map<String, dynamic>> _currencies = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  // Загрузка списка валют
  Future<void> _fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('https://baiel123.pythonanywhere.com/api/currencies/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Фильтрация валют для исключения "som"
          _currencies = List<Map<String, dynamic>>.from(
            data.where((currency) => currency['name'].toLowerCase() != 'som'),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load currencies")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
    }
  }

  // Рассчитать total
  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text);
    final rate = double.tryParse(_rateController.text);

    if (quantity != null && rate != null) {
      setState(() {
        _total = quantity * rate;
      });
    } else {
      setState(() {
        _total = null;
      });
    }
  }

  // Отправка транзакции
  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedCurrencyId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> transactionData = {
      "type": _selectedType,
      "currency": _selectedCurrencyId, // Используем ID выбранной валюты
      "quantity": double.parse(_quantityController.text),
      "rate": double.parse(_rateController.text),
    };

    try {
      final response = await http.post(
        Uri.parse('https://baiel123.pythonanywhere.com/api/transactions/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transactionData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction successful")));
      } else {
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction failed: ${errorResponse['error']}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred: $error")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Create Transaction",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Тип транзакции
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: [
                  DropdownMenuItem(child: Text('Buy'), value: 'buy'),
                  DropdownMenuItem(child: Text('Sell'), value: 'sell'),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null ? 'Please select a type' : null,
              ),

              SizedBox(height: 16),

              // Выбор валюты
              DropdownButtonFormField<int>(
                value: _selectedCurrencyId,
                items: _currencies
                    .map<DropdownMenuItem<int>>((currency) => DropdownMenuItem<int>(
                          value: currency['id'] as int,
                          child: Text(currency['name'] as String),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrencyId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null ? 'Please select a currency' : null,
              ),

              SizedBox(height: 16),

              // Поле для ввода количества
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter quantity' : null,
                onChanged: (value) => _calculateTotal(),
              ),

              SizedBox(height: 16),

              // Поле для ввода курса
              TextFormField(
                controller: _rateController,
                decoration: InputDecoration(
                  labelText: 'Rate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter rate' : null,
                onChanged: (value) => _calculateTotal(),
              ),

              // Total
              if (_total != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Total: $_total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

              // Кнопка отправки данных
              _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.blueAccent,
                    )
                  : ElevatedButton(
                      onPressed: _submitTransaction,
                      child: Text('Submit Transaction'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

              SizedBox(height: 20),

              // Кнопка перехода к истории транзакций
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionHistoryPage(),
                    ),
                  );
                },
                child: Text(
                  "View Transaction History",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}