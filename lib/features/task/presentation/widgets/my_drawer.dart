import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanage/core/common/cubits/app_theme/theme_cubit.dart';
import 'package:taskmanage/core/common/cubits/app_theme/theme_state.dart';
import 'package:taskmanage/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:taskmanage/core/themes/app_pallete.dart';
import 'package:taskmanage/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:taskmanage/features/auth/presentation/pages/login_page.dart';
import 'package:taskmanage/features/task/presentation/layout/task_layout_page.dart';
import 'package:taskmanage/features/task/presentation/pages/settings_page.dart';
import 'package:taskmanage/features/task/presentation/widgets/drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  //final Function(int) onItemSelected;
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select(
        (ThemeCubit cubit) => cubit.state.themeMode == ThemeModeType.dark);
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

    return Drawer(
      backgroundColor:
          isDarkMode ? AppPallete.backgroundColor : AppPallete.whiteColor,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppPallete.gradient1,
            ),
            child: Center(
              child: Image.asset(
                'lib/images/diblog.png',
                width: 150,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Note tile
          DrawerTile(
            title: "Home",
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, TaskLayoutPage.route());
            },
          ),
          DrawerTile(
            title: "Settings",
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const Spacer(),
          // Logout tile
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: DrawerTile(
              title: "Logout",
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogout());
                Navigator.pushAndRemoveUntil(
                  context,
                  LoginPage.route(),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
