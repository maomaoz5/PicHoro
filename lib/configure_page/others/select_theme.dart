import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/theme_provider.dart';
import 'package:horopic/utils/common_functions.dart';

class ChangeTheme extends StatefulWidget {
  const ChangeTheme({super.key});

  @override
  ChangeThemeState createState() => ChangeThemeState();
}

class ChangeThemeState extends State<ChangeTheme> {
  static const Map<String, Color> themeColor = {
    'light': Color(0xFF4596EB),
    'dark': Color(0xFF111213),
    'green': Colors.green,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Color(0xFFE91E63),
    'cyan': Colors.cyan,
    'gold': Color(0xFFFFC107),
    'red': Colors.red,
    'blue': Colors.blue,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'lime': Colors.lime,
    'amber': Colors.amber,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Color(0xFF607D8B),
  };

  Widget _buildColorItem(String key, AppInfoProvider appinfo) {
    bool isSelected = appinfo.keyThemeColor == key;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () => appinfo.setTheme(key),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColor[key]!,
                themeColor[key]!.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: Colors.white, width: 3.0) : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? themeColor[key]!.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: isSelected ? 10 : 4,
                spreadRadius: isSelected ? 2 : 0,
                offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0,
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 28,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomColorItem(AppInfoProvider appinfo) {
    bool isSelected = appinfo.keyThemeColor.startsWith('custom_');
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () => _showCustomColorPicker(appinfo),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE040FB),
                Color(0xFF7C4DFF),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: Colors.white, width: 3.0) : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF7C4DFF).withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: isSelected ? 10 : 4,
                spreadRadius: isSelected ? 2 : 0,
                offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.color_lens,
              color: Colors.white,
              size: 28,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomColorPicker(AppInfoProvider appinfo) {
    Color selectedColor = const Color(0xFF4596EB);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('选择自定义颜色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('选择你喜欢的主题颜色'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                String hexColor = '#${selectedColor.value.toRadixString(16).substring(2)}';
                appinfo.setTheme('custom_$hexColor');
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: getLeadingIcon(context),
          title: titleText('主题设置'),
          flexibleSpace: getFlexibleSpace(context),
        ),
        body: Consumer<AppInfoProvider>(builder: (context, appinfo, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                  child: Text(
                    '主题模式',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                        leading: Icon(Icons.auto_awesome,
                            color: appinfo.keyThemeColor == 'auto' ? Theme.of(context).primaryColor : null),
                        title: const Text('自动(8:00~22:00)', style: TextStyle(fontSize: 16)),
                        trailing: appinfo.keyThemeColor == 'auto'
                            ? CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 12,
                                child: const Icon(Icons.check, color: Colors.white, size: 16))
                            : null,
                        onTap: () => appinfo.setTheme('auto'),
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                        leading: Icon(Icons.light_mode,
                            color: appinfo.keyThemeColor == 'light' ? Theme.of(context).primaryColor : null),
                        title: const Text('浅色主题', style: TextStyle(fontSize: 16)),
                        trailing: appinfo.keyThemeColor == 'light'
                            ? CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 12,
                                child: const Icon(Icons.check, color: Colors.white, size: 16))
                            : null,
                        onTap: () => appinfo.setTheme('light'),
                      ),
                      const Divider(height: 1, indent: 24, endIndent: 24),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                        leading: Icon(Icons.dark_mode, color: appinfo.keyThemeColor == 'dark' ? Colors.white : null),
                        title: const Text('深色主题', style: TextStyle(fontSize: 16)),
                        trailing: appinfo.keyThemeColor == 'dark'
                            ? CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 12,
                                child: const Icon(Icons.check, color: Colors.white, size: 16))
                            : null,
                        onTap: () => appinfo.setTheme('dark'),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                  child: Text(
                    '主题颜色',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                      children: [
                        ...themeColor.keys.map((key) => _buildColorItem(key, appinfo)),
                        _buildCustomColorItem(appinfo),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        }));
  }
}
