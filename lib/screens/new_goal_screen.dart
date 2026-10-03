import 'package:flutter/material.dart';
import 'package:flutter_fund/widgets/amount_field.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _savedAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Goal'), centerTitle: true),
      body: ListView(
        children: [
          TextField(
            controller: _goalNameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hint: Text('Goal Name')),
          ),
          AmountField(
            controller: _targetAmountController,
            label: 'Target Amount',
          ),
        ],
      ),
    );
  }
}
