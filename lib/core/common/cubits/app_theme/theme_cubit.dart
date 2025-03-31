import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../themes/theme.dart';
import 'theme_state.dart'; // Import your ThemeState

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          themeData: AppTheme.lightThemeMode, // Default to dark theme
          themeMode: ThemeModeType.light,
        ));

  // Method to toggle between light and dark themes
  void toggleTheme() {
    if (state.themeMode == ThemeModeType.light) {
      emit(ThemeState(
        themeData: AppTheme.darkThemeMode,
        themeMode: ThemeModeType.dark,
      ));
    } else {
      emit(ThemeState(
        themeData: AppTheme.lightThemeMode,
        themeMode: ThemeModeType.light,
      ));
    }
  }
}
