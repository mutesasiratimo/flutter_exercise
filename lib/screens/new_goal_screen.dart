import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/utils/money.dart';
import 'package:flutter_fund/widgets/amount_field.dart';
import 'package:intl/intl.dart';

class NewGoalScreen extends StatefulWidget {
  final Goal? goal;
  const NewGoalScreen({super.key, this.goal});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final _formKey = GlobalKey<FormState>();
  Currency selectedCurrency = Currency.ugx;
  DateTime? _targetDate;

  @override
  void initState(){
    super.initState();
    final goal = widget.goal;
    if (goal != null) {
      _goalNameController.text = goal.goalName;
      _targetAmountController.text = goal.targetAmount.toInputString();
      selectedCurrency = goal.currency;
      _targetDate = goal.targetDate;
    }
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Amount is required';
    }

    try {
      final amount = Money.parse(text, selectedCurrency.code);
      if (amount.minorUnits <= 0) {
        return 'Amount must be greater than 0';
      }
      return null;
    } on FormatException catch (error) {
      final message = error.message;
      if (message.contains('does not allow decimals') ||
          message.contains('allows at most')) {
        return selectedCurrency.decimals == 0
            ? 'UGX amounts cannot have decimals'
            : '${selectedCurrency.code} allows up to ${selectedCurrency.decimals} decimals';
      }
      return 'Amount must be a number';
    }
  }

  void _createOrUpdateGoal() {
    if (!_formKey.currentState!.validate()) return;

    final target = Money.parse(
      _targetAmountController.text,
      selectedCurrency.code,
    );
    Navigator.pop(
      context,
      Goal(
        goalName: _goalNameController.text.trim(),
        targetAmount: target,
        savedAmount: Money.zero(selectedCurrency),
        contributions: [],
        targetDate: _targetDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.goal == null ? 'New Goal' : 'Edit Goal'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _goalNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hint: Text('Goal Name')),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Name is required';
                }
                if (text.length < 3 || text.length > 40) {
                  return 'Name should be between 3 and 40 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            AmountField(
              controller: _targetAmountController,
              label: 'Target Amount',
              validator: _validateAmount,
            ),
            SizedBox(height: 16),
            DropdownButton<Currency>(
              value: selectedCurrency,
              items: Currency.values
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency.code),
                    ),
                  )
                  .toList(),
              onChanged: (Currency? newValue) {
                if (newValue == null) return;
                setState(() {
                  selectedCurrency = newValue;
                });
                // Re-check decimals when the currency changes.
                _formKey.currentState?.validate();
              },
            ),
            SizedBox(height: 16),
            DateTimeField(
              format: _dateFormat,
              decoration: InputDecoration(hint: Text('Target Date')),
              initialValue: _targetDate,
              onChanged: (date) {
                _targetDate = date;
              },
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createOrUpdateGoal,
              child: Text(widget.goal == null ? 'Create Goal' : 'Update Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
