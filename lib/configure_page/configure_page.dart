import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
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
  StreamSubscription<OtaEvent>? _updateSubscription;
  static const versionCheckInterval = Duration(minutes: 10);

  @override
  void dispose() {
    _updateSubscription?.cancel();
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
          _updateSubscription?.cancel();
          String url = 'https://github.com/maomaoz5/PicHoro/releases/download/v$latestVersion/PicHoro-v$latestVersion-arm64-v8a.apk';
          try {
            _updateSubscription = OtaUpdate()
                .execute(
              url,
              destinationFilename: 'PicHoro-v$latestVersion-arm64-v8a.apk',
            )
                .listen(
              (OtaEvent event) {
                if (event.status == OtaStatus.DOWNLOADING) {
                  showToast('下载进度: ${event.value}%');
                } else if (event.status == OtaStatus.INSTALLING) {
                  showToast('正在安装更新...');
                } else if (event.status == OtaStatus.DOWNLOAD_ERROR) {
                  showToast('下载失败');
                } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                  showToast('权限被拒绝，无法安装更新');
                } else if (event.status == OtaStatus.ALREADY_RUNNING_ERROR) {
                  showToast('更新正在进行中');
                }
              },
              onError: (error) {
                showToast('更新失败: $error');
              },
              onDone: () {
                _updateSubscription = null;
              },
            );
          } catch (e) {
            showToast('更新失败: $e');
          }
        },
      );
    } else {
      return showToast("已是最新版本");
    }
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<AppInfoProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: titleText('设置页面'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: const SizedBox(
                        width: 80,
                        height: 80,
                        child: Image(image: AssetImage('assets/app_icon.png'), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'PicHoro',
                  style: TextStyle(
                    fontSize: 20,
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.new_releases, color: colorScheme.onPrimaryContainer, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            'v$version  →  v$latestVersion',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'v$version',
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildSettingCard(
            title: '基础配置',
            children: [
              _buildSettingItem(
                title: '图床参数设置',
                icon: Icons.cloud_upload,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.allPShost, transition: TransitionType.cupertino),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '常规设置',
                icon: Icons.settings,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.commonConfig, transition: TransitionType.cupertino),
              ),
            ],
          ),
          _buildSettingCard(
            title: '应用信息',
            children: [
              _buildSettingItem(
                title: '软件日志',
                icon: Icons.description,
                onTap: () => Application.router
                    .navigateTo(context, Routes.configurePageLogger, transition: TransitionType.cupertino),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: _updateAvailable ? '有新版本！' : '检查更新',
                icon: Icons.system_update,
                onTap: _checkUpdate,
                subtitle: _isLoading ? const Text('正在检查...') : null,
                trailing: _updateAvailable
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, color: colorScheme.onPrimaryContainer, size: 14),
                            const SizedBox(width: 4),
                            Text('更新', style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outline),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '更新日志',
                icon: Icons.history,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.updateLog, transition: TransitionType.cupertino),
              ),
            ],
          ),
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
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
