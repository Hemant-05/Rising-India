import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/add_new_items/screens/add_new_item_screen.dart';
import 'package:raising_india/features/admin/all_product_list/screens/all_product_list_a.dart';
import 'package:raising_india/features/admin/home/screens/home_screen_a.dart';
import 'package:raising_india/features/admin/notification/screens/notification_screen_a.dart';
import 'package:raising_india/features/admin/profile/screens/profile_screen_a.dart';

class MainScreenA extends StatefulWidget {
  const MainScreenA({super.key});

  @override
  State<MainScreenA> createState() => _MainScreenAState();
}

class _MainScreenAState extends State<MainScreenA> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  int currentIndex = 0;

  List<Widget> pages = [
    const HomeScreenA(),
    const AllProductListA(),
    const AddNewItemScreen(),
    const NotificationScreenA(),
    const ProfileScreenA(),
  ];

  final NavBarStyle _navBarStyle = NavBarStyle.style12;

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(home_svg, color: currentIndex == 0 ? AppColour.primary : AppColour.grey),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(order_icon_svg, color: currentIndex == 1 ? AppColour.primary : AppColour.grey),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(add_new_item_svg,),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(notification_svg, color: currentIndex == 3 ? AppColour.primary : AppColour.grey),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(profile_svg, color: currentIndex == 4 ? AppColour.primary : AppColour.grey),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      onItemSelected: (value) => setState(() {
        currentIndex = value;
      }),
      controller: _controller,
      screens: pages,
      items: _navBarsItems(),
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: AppColour.white,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: _navBarStyle, // Choose the nav bar style with this property
    );
  }
}
