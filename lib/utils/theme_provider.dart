import 'package:flutter/material.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:horopic/configure_page/others/theme_data.dart';

Map<String, ThemeData> themeDataMap = {
  'light': lightThemeData,
  'dark': darkThemeData,
  'green': greenThemeData,
  'purple': purpleThemeData,
  'orange': orangeThemeData,
  'pink': pinkThemeData,
  'cyan': cyanThemeData,
  'gold': goldThemeData,
  'red': redThemeData,
  'blue': blueThemeData,
  'teal': tealThemeData,
  'indigo': indigoThemeData,
  'lime': limeThemeData,
  'amber': amberThemeData,
  'brown': brownThemeData,
  'grey': greyThemeData,
  'blueGrey': blueGreyThemeData,
  ' ': lightThemeData,
};

ThemeData generateCustomThemeData(String hexColor) {
  try {
    Color color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: color),
      fontFamily: 'SystemFont',
    );
  } catch (e) {
    return lightThemeData;
  }
}

class AppInfoProvider with ChangeNotifier {
  String _themeColor = '';
  String get themeColor => _themeColor;

  String _keyThemeColor = ' ';
  String get keyThemeColor => _keyThemeColor;

  AppInfoProvider() {
    _initAsync();
  }

  bool isDarkMode() => _themeColor == 'dark';

  Future<void> _initAsync() async {
    await SpUtil.getInstance();
    String colorset = SpUtil.getString('key_theme_color', defValue: 'light')!;
    _keyThemeColor = colorset;
    setTheme(colorset);
  }

  Future<void> setTheme(String themeColor) async {
    _themeColor =
        themeColor == 'auto' ? (DateTime.now().hour >= 8 && DateTime.now().hour <= 22 ? 'light' : 'dark') : themeColor;

    _keyThemeColor = _themeColor;

    notifyListeners();
    await SpUtil.getInstance();
    SpUtil.putString('key_theme_color', _themeColor);
  }

  ThemeData getThemeData() {
    if (_themeColor.startsWith('custom_')) {
      String hexColor = _themeColor.substring(7);
      return generateCustomThemeData(hexColor);
    }
    return themeDataMap[_themeColor] ?? lightThemeData;
  }
}
