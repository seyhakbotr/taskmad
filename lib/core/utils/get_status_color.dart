import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'todo':
      return Colors.grey;
    case 'in_progress':
      return Colors.blue;
    case 'done':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
