import 'package:flutter/material.dart';

import '../themes/app_pallete.dart';

void showSnackBar(BuildContext context, String content,
    {bool isError = false}) {
  final backgroundColor =
      isError ? AppPallete.errorColor : AppPallete.successColor;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        content,
        style: const TextStyle(color: AppPallete.whiteColor),
      ),
    ));
}
