import 'package:intl/intl.dart';

String formatDueDate(DateTime dateTime) {
  return DateFormat('MMM d, y - h:mm a').format(dateTime);
}
