import 'package:flutter/material.dart';

Widget getFlexibleSpace(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          colorScheme.primary,
          colorScheme.primary.withValues(alpha: 0.85),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}

Widget getLeadingIcon(BuildContext context) {
  final foregroundColor = Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
  return IconButton(
    icon: Icon(Icons.arrow_back_ios, size: 20, color: foregroundColor),
    onPressed: () => Navigator.pop(context),
  );
}
