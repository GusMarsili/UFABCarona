import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:myapp/bloc/bottom_nav_cubit.dart';
import 'package:myapp/pages/pages.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late PageController pageController; //navegar entre as paginas

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

  final List<Widget> topLevelPages = const [
    CaronasPage(),
    UberPage(),
    ReservasPage(),
    PerfilPage(),
    CriarPage(),
  ];

  void onPageChanged(int page) {
    BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _mainWrapperAppBar(),
      bottomNavigationBar: _mainWrapperBottomNavBar(context),
      floatingActionButton: _mainWrappedFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _mainWrapperBody(),
    );
  }

  PageView _mainWrapperBody() {
    return PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      children: topLevelPages,
    );
  }

  // Widget _mainWrapperBody() => PageView(
  //   return PageView(
  //     controller: pageController,
  //     children: topLevelPages,
  //   );
  // )

  AppBar _mainWrapperAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinhar à esquerda
        children: [
          Image.asset(
            'lib/images/logo-degrade.png', // Substitua pelo caminho real da sua imagem
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
    required defaultIcon,
    required page,
    required label,
    required filledIcon,
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
              color:
                  context.watch<BottomNavCubit>().state == page
                      ? Color(0xFF336600)
                      : Colors.black,
              size: 30,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color:
                    context.watch<BottomNavCubit>().state == page
                        ? Color(0xFF336600)
                        : Colors.black,
                fontSize: 13,
                fontWeight:
                    context.watch<BottomNavCubit>().state == page
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
      color: Color.fromARGB(255, 255, 255, 255),

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

          //const SizedBox(width: 80, height: 20),
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => CriarPage()),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     behavior: SnackBarBehavior.floating,
        //     backgroundColor: Color.fromARGB(255, 72, 255, 0),
        //     content: Text("Nova carona"),
        //   ),
        // );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: Color(0xFFFFCC00),
      child: const Icon(Icons.add, size: 30),
    );
  }
}
