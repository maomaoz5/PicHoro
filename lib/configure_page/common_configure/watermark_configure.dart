import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class WatermarkConfigure extends StatefulWidget {
  const WatermarkConfigure({super.key});

  @override
  WatermarkConfigureState createState() => WatermarkConfigureState();
}

class WatermarkConfigureState extends State<WatermarkConfigure> {
  final _textController = TextEditingController(text: Global.watermarkText);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget child,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor ??
                  Theme.of(context).primaryColor.withValues(
                        alpha: 0.2,
                      ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _positionLabels = {
    'topLeft': '左上角',
    'topRight': '右上角',
    'bottomLeft': '左下角',
    'bottomRight': '右下角',
    'center': '居中',
  };

  static const _sizeLabels = {
    'small': '小',
    'medium': '中',
    'large': '大',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('水印设置'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 8),
          _buildSettingCard(
            title: '水印模式',
            children: [
              _buildSettingItem(
                icon: Icons.style,
                label: '水印类型',
                child: DropdownButton<String>(
                  value: Global.watermarkMode,
                  isExpanded: true,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('文字水印')),
                    DropdownMenuItem(value: 'image', child: Text('图片水印')),
                  ].toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Global.setWatermarkMode(value);
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
          if (Global.watermarkMode == 'text')
            _buildSettingCard(
              title: '文字水印',
              children: [
                _buildSettingItem(
                  icon: Icons.text_fields,
                  label: '水印文字',
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '输入水印文字内容',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) => Global.setWatermarkText(value),
                  ),
                ),
              ],
            ),
          if (Global.watermarkMode == 'image')
            _buildSettingCard(
              title: '图片水印',
              children: [
                _buildSettingItem(
                  icon: Icons.image,
                  label: '水印图片',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Global.watermarkImagePath.isEmpty
                              ? '未选择图片'
                              : Global.watermarkImagePath.split('/').last,
                          style: TextStyle(
                            fontSize: 12,
                            color: Global.watermarkImagePath.isEmpty ? Colors.grey : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickWatermarkImage,
                        child: const Text('选择图片'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          _buildSettingCard(
            title: '水印样式',
            children: [
              _buildSettingItem(
                icon: Icons.location_on,
                label: '水印位置',
                child: DropdownButton<String>(
                  value: Global.watermarkPosition,
                  isExpanded: true,
                  underline: Container(),
                  items: _positionLabels.entries.map((e) {
                    return DropdownMenuItem(value: e.key, child: Text(e.value));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Global.setWatermarkPosition(value);
                      setState(() {});
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.opacity,
                label: '水印透明度',
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: Global.watermarkOpacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label: '${(Global.watermarkOpacity * 100).round()}%',
                        onChanged: (value) {
                          Global.setWatermarkOpacity(value);
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${(Global.watermarkOpacity * 100).round()}%',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.format_size,
                label: Global.watermarkMode == 'text' ? '字体大小' : '水印大小',
                child: DropdownButton<String>(
                  value: Global.watermarkFontSize,
                  isExpanded: true,
                  underline: Container(),
                  items: _sizeLabels.entries.map((e) {
                    return DropdownMenuItem(value: e.key, child: Text(e.value));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Global.setWatermarkFontSize(value);
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickWatermarkImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          if (!await File(path).exists()) {
            showToast('文件不存在');
            return;
          }
          Global.setWatermarkImagePath(path);
          setState(() {});
          showToast('已选择水印图片');
        }
      }
    } catch (e) {
      showToast('选择失败: $e');
    }
  }
}
