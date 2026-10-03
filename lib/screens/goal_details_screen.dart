import 'package:flutter/material.dart';
import '/models/goal.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;
  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Goal Details'), centerTitle: true),
      body: Center(child: Text(widget.goal.goalName)),
    );
  }
}
