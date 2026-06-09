import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:koopcare/core/widgets/custom_bottom_nav.dart';
import 'package:koopcare/features/home/presentation/pages/beranda_page.dart';
import 'package:koopcare/features/simpanan_dana/presentation/pages/simpanan_dana_page.dart';
import 'package:koopcare/features/loan/presentation/pages/cicilan_page.dart';
import 'package:koopcare/features/account/presentation/pages/account_page.dart';
import 'presentation/cubit/navigation_cubit.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      BerandaPage(),
      SimpananDanaPage(),
      DetailPembiayaanPage(),
      ProfilePage(),
    ];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: selectedIndex,
            onTap: (index) => context.read<NavigationCubit>().changeTab(index),
          ),
        );
      },
    );
  }
}
