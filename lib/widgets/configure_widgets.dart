import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class ConfigureWidgets {
  static Widget buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  static Widget buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Widget? subtitle,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = iconColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final fgColor = iconColor ?? colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: fgColor, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle,
      onTap: onTap,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outline),
    );
  }

  static Widget buildFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
        validator: validator,
      ),
    );
  }

  static AppBar buildConfigAppBar({required String title, required BuildContext context}) {
    return AppBar(
      leading: getLeadingIcon(context),
      title: titleText(title, fontsize: 18),
      flexibleSpace: getFlexibleSpace(context),
    );
  }

  static Widget buildDivider() {
    return const Divider();
  }
}
