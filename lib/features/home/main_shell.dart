import 'package:flutter/material.dart';
import 'beranda_page.dart';
import '../../core/app_colors.dart';
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
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home_rounded,                    'label': 'Beranda'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Simpanan'},
      {'icon': Icons.receipt_long_outlined,           'label': 'Cicilan'},
      {'icon': Icons.person_outline_rounded,          'label': 'Akun'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: kPutih,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: active ? 36 : 0,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: kHijauTua,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        items[i]['icon'] as IconData,
                        color: active ? kHijauTua : kAbuAbu,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? kHijauTua : kAbuAbu,
                          fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

