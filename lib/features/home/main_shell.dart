import 'package:flutter/material.dart';
import 'beranda_page.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'account_page.dart';
import 'simpanan_dana_page.dart';
import 'cicilan_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BerandaPage(onSwitchTab: (i) => setState(() => _selectedIndex = i)),
      const SimpananDanaPage(),
      const DetailPembiayaanPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

