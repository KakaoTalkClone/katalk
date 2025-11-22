// lib/shared/widgets/k_bottom_nav.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';

const _kNavIconBase = Color(0xFF696B6D);     
const _kNavIconSelected = Color(0xFFE3E9F0);
const _kNavBg = Color(0xFF111113);         
const _kTopDivider = Color(0xFF212123);    

class KBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const KBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding.bottom; //
    final bottomPadding = (safe > 0 ? safe : 10.0) + 1;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      height: 53 + bottomPadding,
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(
          top: BorderSide(color: _kTopDivider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            isSelected: currentIndex == 0,
            icon: CupertinoIcons.person_solid,
            label: ' ',
            onTap: onTap,
          ),
          _NavItem(
            index: 1,
            isSelected: currentIndex == 1,
            icon: CupertinoIcons.chat_bubble_text_fill,
            label: ' ',
            onTap: onTap,
          ),
          _NavItem(
            index: 2,
            isSelected: currentIndex == 2,
            icon: CupertinoIcons.bell_solid, // 오픈채팅(대체)
            label: ' ',
            onTap: onTap,
          ),
          _NavItem(
            index: 3,
            isSelected: currentIndex == 3,
            icon: CupertinoIcons.bag_fill, // 쇼핑
            label: ' ',
            onTap: onTap,
          ),
          _MoreItem(
            index: 4,
            isSelected: currentIndex == 4,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

/// 일반 항목
class _NavItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final IconData icon;
  final String label;
  final void Function(int) onTap;

  const _NavItem({
    required this.index,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? _kNavIconSelected : _kNavIconBase;

    return InkWell(
      onTap: () => onTap(index),
      child: const SizedBox(width: 64) 
          .withHeight(62, child: Center(
        child: IconTheme(
          data: const IconThemeData(opacity: 1.0, size: 24),
          child: Icon(icon, color: iconColor),
        ),
      )),
    );
  }
}

/// 우측 '더보기' 항목 (도트/뱃지 제거)
class _MoreItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final void Function(int) onTap;

  const _MoreItem({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? _kNavIconSelected : _kNavIconBase;

    return InkWell(
      onTap: () => onTap(index),
      child: const SizedBox(width: 64)
          .withHeight(62, child: Center(
        child: IconTheme(
          data: const IconThemeData(opacity: 1.0, size: 26),
          child: Icon(CupertinoIcons.ellipsis_circle_fill, color: iconColor),
        ),
      )),
    );
  }
}

/// --- 작은 유틸: SizedBox에 높이와 child를 함께 주기 위한 확장 ---
extension _SizedBoxExt on SizedBox {
  SizedBox withHeight(double h, {required Widget child}) =>
      SizedBox(width: width, height: h, child: child);
}
