import 'package:flutter/material.dart';
import 'package:taskmanage/features/task/presentation/pages/task_page.dart';
import 'package:taskmanage/features/task/presentation/pages/calendar_page.dart';

import '../../../../core/common/widgets/bottom_nav_bar.dart';

class TaskLayoutPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const TaskLayoutPage(),
      );
  const TaskLayoutPage({super.key});

  @override
  State<TaskLayoutPage> createState() => _TaskLayoutPageState();
}

class _TaskLayoutPageState extends State<TaskLayoutPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TaskPage(),
    CalendarPage()
    // Add more pages here as needed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: _onItemTapped,
      ),
    );
  }
}
