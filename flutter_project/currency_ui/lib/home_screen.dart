import 'package:flutter/material.dart';
import 'currencies_page.dart';
import 'screens/transactions_page.dart';
import 'report_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CurrenciesPage()));
              },
              child: Text('Go to Currencies'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/transaction');
              },
              child: Text('Go to Transaction'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReportPage()));
              },
              child: Text('Go to Report'),
            ),
          ],
        ),
      ),
    );
  }
}
