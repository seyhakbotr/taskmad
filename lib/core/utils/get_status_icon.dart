import 'package:flutter/material.dart';

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'todo':
      return Icons.radio_button_unchecked;
    case 'in_progress':
      return Icons.autorenew;
    case 'done':
      return Icons.check_circle;
    default:
      return Icons.radio_button_unchecked;
  }
}
