import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import '../bloc/bottom_nav_cubit.dart';
import '../pages/pages.dart';

class MainWrapper extends StatefulWidget {
  final User user;
  const MainWrapper({super.key, required this.user});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late PageController pageController; // Navega entre as páginas

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final List<Widget> topLevelPages = [];

  void onPageChanged(int page) {
    BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> topLevelPages = [
      CaronasPage(user: widget.user),
      UberPage(user: widget.user),
      ReservasPage(user: widget.user),
      PerfilPage(user: widget.user),
      CriarPage(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _mainWrapperAppBar(),
      bottomNavigationBar: _mainWrapperBottomNavBar(context),
      floatingActionButton: _mainWrappedFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _mainWrapperBody(topLevelPages),
    );
  }

  PageView _mainWrapperBody(List<Widget> pages) {
    return PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      children: pages,
    );
  }

  AppBar _mainWrapperAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/images/logo-degrade.png',
            height: 50,
          ),
          Text(
            "UFABCarona",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem(
    BuildContext context, {
    required IconData defaultIcon,
    required int page,
    required String label,
    required IconData filledIcon,
  }) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 10),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Icon(
              context.watch<BottomNavCubit>().state == page
                  ? filledIcon
                  : defaultIcon,
              color: context.watch<BottomNavCubit>().state == page
                  ? const Color(0xFF336600)
                  : Colors.black,
              size: 30,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: context.watch<BottomNavCubit>().state == page
                    ? const Color(0xFF336600)
                    : Colors.black,
                fontSize: 13,
                fontWeight: context.watch<BottomNavCubit>().state == page
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomAppBar _mainWrapperBottomNavBar(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.search,
                  page: 0,
                  label: "Buscar",
                  filledIcon: IconlyBold.search,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.user_1,
                  page: 1,
                  label: "UBER",
                  filledIcon: IconlyBold.user_3,
                ),
                Container(color: Colors.transparent, width: 15, height: 50),
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.notification,
                  page: 2,
                  label: "Reservas",
                  filledIcon: IconlyBold.notification,
                ),
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.profile,
                  page: 3,
                  label: "Perfil",
                  filledIcon: IconlyBold.profile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton _mainWrappedFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(4);
        pageController.animateToPage(
          4,
          duration: const Duration(milliseconds: 10),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: const Color(0xFFFFCC00),
      child: const Icon(Icons.add, size: 30),
    );
  }
}