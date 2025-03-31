import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void dd(dynamic value, {String? label, bool die = false}) {
  // Default to false for 'die'
  final output = StringBuffer();

  if (label != null) {
    output.writeln('[$label] ${'-' * 50}');
  }

  // Pretty print the value
  output.writeln(prettyPrint(value));

  // Add stack trace
  output.writeln('\nStackTrace:');
  output.writeln(StackTrace.current.toString());

  debugPrint(output.toString());

  // Don't stop the program, just print the output
  // If 'die' is true, it would still trigger, but it's defaulted to false now
  if (die) {
    assert(() {
      // Optionally, you can handle some debugging or custom exit behavior here,
      // but I removed the exit(0) to prevent stopping the program.
      return true;
    }());
  }
}

String prettyPrint(dynamic value) {
  if (value is Map || value is Iterable) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }
  return value.toString();
}
