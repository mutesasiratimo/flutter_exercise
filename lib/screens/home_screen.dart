import 'package:flutter/material.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/screens/goal_details_screen.dart';
import 'package:flutter_fund/screens/new_goal_screen.dart';
import 'package:flutter_fund/utils/format.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalSavedAcross = 0;
  List<Goal> savingsGoals = [
    Goal(
      goalName: 'New phone',
      targetAmount: 100000,
      savedAmount: 0,
      contributions: [],
    ),
    Goal(
      goalName: 'Vacation',
      targetAmount: 100000,
      savedAmount: 0,
      contributions: [],
    ),
    Goal(
      goalName: 'Car',
      targetAmount: 4000000,
      savedAmount: 0,
      contributions: [],
    ),
    Goal(
      goalName: 'Laptop',
      targetAmount: 100000,
      savedAmount: 0,
      contributions: [],
    ),
    Goal(
      goalName: 'Rainy Day',
      targetAmount: 500000,
      savedAmount: 0,
      contributions: [],
    ),
  ];

  void _addSavingsGoal(int index) {
    setState(() {
      var goal = savingsGoals[index];
      final target = goal.targetAmount;
      final saved = (goal.savedAmount) + 10000;

      savingsGoals[index] = goal.copyWith(
        savedAmount: saved > target ? target : saved,
      );
    });

    _computeTotalSavedAcrossAllGoals();
  }

  void _computeTotalSavedAcrossAllGoals() {
    totalSavedAcross = 0;
    for (Goal i in savingsGoals) {
      totalSavedAcross += i.savedAmount;
    }
  }

  void _createNewGoal(Goal goal) {
    debugPrint(goal.goalName);
    setState(() {
      savingsGoals.add(goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Fund'), centerTitle: true),
      body: Column(
        children: [
          Text(
            'Total Amount Saved: UGX ${AppFunctions.numberFormat(totalSavedAcross)}',
          ),
          Expanded(
            child: ListView.builder(
              itemCount: savingsGoals.length,
              itemBuilder: (context, index) {
                var goal = savingsGoals[index];
                num savedAmount = double.parse(goal.savedAmount.toString());
                num targetAmount = double.parse(goal.targetAmount.toString());
                double progress = savedAmount / targetAmount;
                return Card(
                  child: ListTile(
                    title: Text(goal.goalName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UGX ${AppFunctions.numberFormat(goal.savedAmount)} of UGX ${AppFunctions.numberFormat(goal.targetAmount)} (${(progress * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(),
                        ),
                        LinearProgressIndicator(
                          value: progress,
                          semanticsLabel: 'Progress: $progress',
                        ),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () =>
                          progress < 1 ? _addSavingsGoal(index) : null,
                      label: Text(
                        progress < 1
                            ? 'Add ${AppFunctions.numberFormat(10000)}'
                            : 'Completed',
                      ),
                      icon: progress < 1
                          ? Icon(Icons.add)
                          : Icon(Icons.check_circle),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => GoalDetailsScreen(goal: goal),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        icon: Icon(Icons.add),
        style: IconButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => NewGoalScreen()),
        ),
      ),
    );
  }
}
