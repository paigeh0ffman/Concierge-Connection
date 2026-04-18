/* Navigation bar widget

Authors: Paige Hoffman

Citations: fluttertemplates.dev, Claude.ai
 */
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isDoctor;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFF00C9A7),
      unselectedItemColor: const Color(0xFF6B6B80),
      backgroundColor: const Color(0xFF16161F),
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: isDoctor ? _doctorItems : _patientItems,
    );
  }
}

const _doctorItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.dashboard_outlined),
    activeIcon: Icon(Icons.dashboard_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.chat_bubble_outline_rounded),
    activeIcon: Icon(Icons.chat_bubble_rounded),
    label: 'Chat',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.monitor_heart_outlined),
    activeIcon: Icon(Icons.monitor_heart_rounded),
    label: 'Tracker',
  ),
];

const _patientItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.chat_bubble_outline_rounded),
    activeIcon: Icon(Icons.chat_bubble_rounded),
    label: 'Chat',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.favorite_border_rounded),
    activeIcon: Icon(Icons.favorite_rounded),
    label: 'Tracker',
  ),
];