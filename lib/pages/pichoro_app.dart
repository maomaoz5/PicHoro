import 'package:flutter/material.dart';
import 'package:horopic/pages/home_page.dart';
import 'package:horopic/album/album_page.dart';
import 'package:horopic/configure_page/configure_page.dart';
import 'package:horopic/picture_host_manage/picture_host_manage_entry.dart';

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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
