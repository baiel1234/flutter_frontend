import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTransactionDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final Function(Map<String, dynamic>) onSave;

  EditTransactionDialog({required this.transaction, required this.onSave});

  @override
  _EditTransactionDialogState createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _quantity;
  late String _rate;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction['type'];
    _quantity = widget.transaction['quantity'].toString();
    _rate = widget.transaction['rate'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        "Edit Transaction",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueAccent,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: [
                  DropdownMenuItem(
                    child: Text("Buy"),
                    value: "buy",
                  ),
                  DropdownMenuItem(
                    child: Text("Sell"),
                    value: "sell",
                  ),
                ],
                onChanged: (value) => setState(() => _type = value!),
                decoration: InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => _quantity = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _rate,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Rate",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => _rate = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
          ),
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'type': _type,
                'quantity': double.parse(_quantity),
                'rate': double.parse(_rate),
              });
              Navigator.pop(context);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
          ),
          child: Text(
            "Save",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
