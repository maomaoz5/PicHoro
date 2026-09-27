import 'package:flutter/material.dart';

Widget getFlexibleSpace(BuildContext context) {
  return const SizedBox.shrink();
}

Widget getLeadingIcon(BuildContext context) {
  final foregroundColor = Theme.of(context).colorScheme.onSurface;
  return IconButton(
    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: foregroundColor),
    onPressed: () => Navigator.pop(context),
  );
}
