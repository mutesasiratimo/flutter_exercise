import 'package:flutter/material.dart';

import 'design_constants.dart';

class EmptyState extends StatefulWidget {
  final VoidCallback onNewGoal;
  final ThemeData theme;
  const EmptyState({super.key, required this.onNewGoal, required this.theme});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 64,
            color: widget.theme.colorScheme.primary,
          ),
          const SizedBox(height: DesignConstants.padding),
          Text('Create your first goal', style: widget.theme.textTheme.titleMedium),
          const SizedBox(height: DesignConstants.padding),
          FilledButton.icon(
            onPressed: widget.onNewGoal,
            icon: const Icon(Icons.add),
            label: const Text('New goal'),
          ),
        ],
      ),
    );
  }
}