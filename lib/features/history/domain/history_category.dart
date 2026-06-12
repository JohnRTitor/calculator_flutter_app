import 'package:flutter/material.dart';

/// Represents the different modules in the calculator that generate history.
enum HistoryCategory {
  calculator('Calculator', Icons.calculate),
  functionEvaluator('Fn Evaluator', Icons.functions),
  modularArithmetic('Modular Math', Icons.architecture);

  final String label;
  final IconData icon;

  const HistoryCategory(this.label, this.icon);
}
