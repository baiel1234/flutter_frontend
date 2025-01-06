import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'screens/transactions_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Example',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/transaction': (context) => TransactionPage(), // Страница транзакции
      },
    );
  }
}
