import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/theme_provider.dart';

class ConfigurePage extends StatefulWidget {
  const ConfigurePage({super.key});

  @override
  ConfigurePageState createState() => ConfigurePageState();
}

class ConfigurePageState extends State<ConfigurePage> with AutomaticKeepAliveClientMixin<ConfigurePage> {
  String version = ' ';
  String latestVersion = ' ';
  bool _isLoading = false;
  bool _updateAvailable = false;
  DateTime? _lastVersionCheck;
  CancelToken? _downloadCancelToken;
  bool _isDownloading = false;
  static const versionCheckInterval = Duration(minutes: 10);

  @override
  void dispose() {
    _downloadCancelToken?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _initPageData();
  }

  void _initPageData() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        version = info.version;
      });
    }
    _checkVersionInBackground();
  }

  void _checkVersionInBackground() async {
    final now = DateTime.now();
    if (_lastVersionCheck != null && now.difference(_lastVersionCheck!) < versionCheckInterval) {
      return;
    }
    _lastVersionCheck = now;

    String remoteVersion = await getRemoteVersion();
    if (mounted) {
      setState(() {
        latestVersion = remoteVersion;
        _updateAvailable = _isUpdateAvailable(version, remoteVersion);
      });
    }
  }

  Future<String> getRemoteVersion() async {
    const url = 'https://api.github.com/repos/maomaoz5/PicHoro/releases/latest';
    try {
      Response response = await Dio().get(url, options: Options(headers: {'Accept': 'application/vnd.github+json'}));
      String tagName = response.data['tag_name'] ?? '';
      return tagName.replaceFirst('v', '');
    } catch (e) {
      return ' ';
    }
  }

  bool _isUpdateAvailable(String currentVersion, String remoteVersion) {
    if (remoteVersion == ' ') return false;
    try {
      List<int> currentParts = currentVersion.split('.').map((part) => int.parse(part)).toList();
      List<int> remoteParts = remoteVersion.split('.').map((part) => int.parse(part)).toList();
      for (int i = 0; i < currentParts.length && i < remoteParts.length; i++) {
        if (remoteParts[i] > currentParts[i]) return true;
        if (remoteParts[i] < currentParts[i]) return false;
      }
      return remoteParts.length > currentParts.length;
    } catch (e) {
      return remoteVersion != currentVersion;
    }
  }

  _checkUpdate() async {
    if (_isLoading) {
      return showToast("正在获取版本信息");
    }

    if (latestVersion == ' ') {
      setState(() => _isLoading = true);
      String remoteVersion = await getRemoteVersion();
      setState(() {
        latestVersion = remoteVersion;
        _updateAvailable = _isUpdateAvailable(version, remoteVersion);
        _isLoading = false;
      });
    }

    if (_updateAvailable) {
      showCupertinoAlertDialogWithConfirmFunc(
        title: '通知',
        content: '发现新版本$latestVersion,当前版本$version,是否更新?',
        context: context,
        onConfirm: () async {
          if (_isDownloading) return showToast('正在下载中，请稍候');
          _downloadCancelToken?.cancel();
          _downloadCancelToken = CancelToken();
          String url = 'https://github.com/maomaoz5/PicHoro/releases/download/v$latestVersion/PicHoro-v$latestVersion-arm64-v8a.apk';
          String filename = 'PicHoro-v$latestVersion-arm64-v8a.apk';
          try {
            final dir = await getApplicationDocumentsDirectory();
            final savePath = '${dir.path}/$filename';
            final file = File(savePath);
            if (await file.exists()) await file.delete();

            _isDownloading = true;
            int lastShownPercent = -1;
            await Dio().download(
              url,
              savePath,
              cancelToken: _downloadCancelToken!,
              onReceiveProgress: (count, total) {
                if (total <= 0) return;
                int percent = (count * 100 / total).round();
                if (percent != lastShownPercent) {
                  lastShownPercent = percent;
                  showToast('下载进度：$percent%');
                }
              },
            );
            _isDownloading = false;
            showToast('下载完成，正在打开安装包');
            OpenFilex.open(savePath, type: 'application/vnd.android.package-archive');
          } on DioException catch (e) {
            _isDownloading = false;
            if (e.type == DioExceptionType.cancel) {
              showToast('下载已取消');
            } else {
              showToast('下载失败：${e.message}');
            }
          } catch (e) {
            _isDownloading = false;
            showToast('更新失败：$e');
          }
        },
      );
    } else {
      return showToast("已是最新版本");
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Widget? subtitle,
    bool showDivider = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = iconColor ?? colorScheme.primaryContainer;
    final fgColor = iconColor ?? colorScheme.onPrimaryContainer;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: fgColor, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          subtitle: subtitle,
          onTap: onTap,
          trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
        ),
        if (showDivider) const Divider(height: 1, indent: 56),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<AppInfoProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: titleText('设置'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // App Info Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const SizedBox(
                        width: 72,
                        height: 72,
                        child: Image(image: AssetImage('assets/app_icon.png'), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'PicHoro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                if (_updateAvailable)
                  GestureDetector(
                    onTap: _checkUpdate,
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.new_releases, color: colorScheme.onPrimaryContainer, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            'v$version  →  v$latestVersion',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'v$version',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),

          // Basic Settings
          _buildSettingCard(
            title: '基础配置',
            children: [
              _buildSettingItem(
                title: '图床参数设置',
                icon: Icons.cloud_upload,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.allPShost, transition: TransitionType.cupertino),
              ),
              _buildSettingItem(
                title: '常规设置',
                icon: Icons.settings,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.commonConfig, transition: TransitionType.cupertino),
                showDivider: false,
              ),
            ],
          ),

          // Appearance
          _buildSettingCard(
            title: '外观',
            children: [
              Consumer<AppInfoProvider>(
                builder: (context, appInfo, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.blur_on, color: colorScheme.onPrimaryContainer, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('模糊强度', style: const TextStyle(fontSize: 15)),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: appInfo.blurSigma,
                                  min: 5,
                                  max: 50,
                                  divisions: 45,
                                  label: '${appInfo.blurSigma.round()}',
                                  onChanged: (value) => appInfo.setBlurSigma(value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // App Info
          _buildSettingCard(
            title: '应用信息',
            children: [
              _buildSettingItem(
                title: '软件日志',
                icon: Icons.description,
                onTap: () => Application.router
                    .navigateTo(context, Routes.configurePageLogger, transition: TransitionType.cupertino),
              ),
              _buildSettingItem(
                title: _updateAvailable ? '有新版本！' : '检查更新',
                icon: Icons.system_update,
                onTap: _checkUpdate,
                subtitle: _isLoading ? const Text('正在检查...') : null,
                trailing: _updateAvailable
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, color: colorScheme.onPrimaryContainer, size: 13),
                            const SizedBox(width: 4),
                            Text('更新', style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
              ),
              _buildSettingItem(
                title: '更新日志',
                icon: Icons.history,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.updateLog, transition: TransitionType.cupertino),
                showDivider: false,
              ),
            ],
          ),

          // Help
          _buildSettingCard(
            title: '帮助',
            children: [
              _buildSettingItem(
                title: '使用手册',
                icon: Icons.menu_book,
                onTap: () async {
                  Application.router.navigateTo(
                    context,
                    '${Routes.webviewPage}?url=${Uri.encodeComponent('https://pichoro.horosama.com')}&title=${Uri.encodeComponent('使用手册')}&enableJs=${Uri.encodeComponent('true')}',
                    transition: TransitionType.inFromRight,
                  );
                },
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 32),
          const SizedBox(height: 84),
        ],
      ),
    );
  }
}
