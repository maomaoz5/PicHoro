import 'package:flutter/material.dart';

const int lightPrimaryValue = 0xFF4596EB;
const int darkPrimaryValue = 0xFF111213;
const int greenPrimaryValue = 0xFF4CAF50;
const int purplePrimaryValue = 0xFF673AB7;
const int orangePrimaryValue = 0xFFFF9800;
const int pinkPrimaryValue = 0xFFF8BBD0;
const int cyanPrimaryValue = 0xFF00BCD4;
const int goldPrimaryValue = 0xFFFFC107;

class AppThemeData {
  final String name;
  final int primaryValue;
  final Brightness brightness;

  const AppThemeData({
    required this.name,
    required this.primaryValue,
    this.brightness = Brightness.light,
  });
}

final List<AppThemeData> availableThemes = [
  const AppThemeData(name: 'Light', primaryValue: lightPrimaryValue),
  const AppThemeData(name: 'Dark', primaryValue: darkPrimaryValue, brightness: Brightness.dark),
  const AppThemeData(name: 'Green', primaryValue: greenPrimaryValue),
  const AppThemeData(name: 'Purple', primaryValue: purplePrimaryValue),
  const AppThemeData(name: 'Orange', primaryValue: orangePrimaryValue),
  const AppThemeData(name: 'Pink', primaryValue: pinkPrimaryValue),
  const AppThemeData(name: 'Cyan', primaryValue: cyanPrimaryValue),
  const AppThemeData(name: 'Gold', primaryValue: goldPrimaryValue),
];

ThemeData generateThemeData(AppThemeData themeData) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Color(themeData.primaryValue),
    brightness: themeData.brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'SystemFont',
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.primary.withValues(alpha: 0.05),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      iconColor: colorScheme.primary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.primary.withValues(alpha: 0.05),
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface);
        }
        return TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onSurface, size: 24);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    ),
    dividerTheme: DividerThemeData(
      thickness: 0.5,
      indent: 56,
      color: colorScheme.outlineVariant,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.onPrimary;
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.surfaceContainerHighest;
      }),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

final ThemeData lightThemeData = generateThemeData(availableThemes[0]);
final ThemeData darkThemeData = generateThemeData(availableThemes[1]);
final ThemeData greenThemeData = generateThemeData(availableThemes[2]);
final ThemeData purpleThemeData = generateThemeData(availableThemes[3]);
final ThemeData orangeThemeData = generateThemeData(availableThemes[4]);
final ThemeData pinkThemeData = generateThemeData(availableThemes[5]);
final ThemeData cyanThemeData = generateThemeData(availableThemes[6]);
final ThemeData goldThemeData = generateThemeData(availableThemes[7]);
