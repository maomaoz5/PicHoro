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

  static const _navItems = <({IconData icon, IconData selectedIcon})>[
    (icon: Icons.file_upload_outlined, selectedIcon: Icons.file_upload),
    (icon: Icons.photo_outlined, selectedIcon: Icons.photo),
    (icon: Icons.storage_outlined, selectedIcon: Icons.storage),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _selectedIndex);
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round();
    if (page != null && page != _selectedIndex) {
      setState(() => _selectedIndex = page);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final blurSigma = context.watch<AppInfoProvider>().blurSigma;
    final blurAlpha = (0.96 - (blurSigma / 50) * 0.08).clamp(0.88, 0.96);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: blurAlpha),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _CapsuleNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                  colorScheme: colorScheme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsuleNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final ColorScheme colorScheme;

  const _CapsuleNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = 64.0;
    const indicatorWidth = 120.0;
    const indicatorHeight = 44.0;
    const itemCount = 4;

    return SizedBox(
      height: barHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / itemCount;
          final indicatorLeft = itemWidth * (selectedIndex + 0.5) - indicatorWidth / 2;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: (barHeight - indicatorHeight) / 2,
                left: indicatorLeft,
                child: Container(
                  width: indicatorWidth,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Row(
                children: List.generate(itemCount, (i) {
                  final item = _PicHoroAPPState._navItems[i];
                  final isSelected = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onItemTapped(i),
                      child: Center(
                        child: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
