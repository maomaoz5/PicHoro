import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:horopic/pages/home_page.dart';
import 'package:horopic/album/album_page.dart';
import 'package:horopic/configure_page/configure_page.dart';
import 'package:horopic/picture_host_manage/picture_host_manage_entry.dart';
import 'package:horopic/utils/theme_provider.dart';

class PicHoroAPP extends StatefulWidget {
  final int selectedIndex;

  const PicHoroAPP({super.key, this.selectedIndex = 0});

  @override
  State<PicHoroAPP> createState() => _PicHoroAPPState();
}

class _PicHoroAPPState extends State<PicHoroAPP> {
  late int _selectedIndex;
  late final PageController _pageController;

  final List<Widget> _pages = const [
    HomePage(),
    UploadedImages(),
    PsHostHomePage(),
    ConfigurePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final blurSigma = context.watch<AppInfoProvider>().blurSigma;
    final blurAlpha = (0.95 - (blurSigma / 40) * 0.2).clamp(0.72, 0.95);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: blurAlpha),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.file_upload_outlined),
                      selectedIcon: Icon(Icons.file_upload),
                      label: '上传',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.photo_outlined),
                      selectedIcon: Icon(Icons.photo),
                      label: '相册',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.storage_outlined),
                      selectedIcon: Icon(Icons.storage),
                      label: '仓库',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: '设置',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
