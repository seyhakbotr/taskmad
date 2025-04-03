import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../themes/app_pallete.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int) onTabChange;

  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Reduced padding
      decoration: const BoxDecoration(
        color: AppPallete.backgroundColor, // Dark background for the nav bar
        border: Border(
          top: BorderSide(
            color: AppPallete.borderColor,
            width: 1.0, // A slight border at the top for separation
          ),
        ),
      ),
      child: GNav(
        backgroundColor: AppPallete.backgroundColor,
        color: AppPallete.greyColor, // Inactive icon color
        activeColor: Colors.white, // Active icon and text color
        tabBackgroundColor: AppPallete.gradient1,
        tabBorderRadius: 16,
        gap: 8,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        iconSize: 20,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white, // Explicitly set text color here
        ),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        onTabChange: (value) => onTabChange(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Tasks',
          ),
          GButton(
            icon: Icons.calendar_view_week_outlined,
            text: 'Calendar',
          ),
        ],
      ),
    );
  }
}
