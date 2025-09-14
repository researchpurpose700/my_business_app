//main screen dart code
import 'package:flutter/material.dart';
import 'package:my_business_app/screens/profile_page.dart';
import 'package:my_business_app/screens/home_page.dart';
import 'package:my_business_app/screens/order_page.dart';
import 'package:my_business_app/screens/listings.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Pages are content-only (no Scaffold inside)
  final List<Widget> _pages = <Widget>[
    HomePage(),
    const OrderPage(),
    const listingPage(),
    const ProfileScreen(), // <-- this must match the class name in profile_page.dart
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: Color(0xfff1f1f1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 90,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                NavItem(
                  index: 0,
                  icon: Icons.home_rounded,              // NEW
                  label: 'HOME',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                NavItem(
                  index: 1,
                  icon: Icons.receipt_long_rounded,      // NEW
                  label: 'ORDERS',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                NavItem(
                  index: 2,
                  icon: Icons.grid_view_rounded,         // NEW
                  label: 'LISTING',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                NavItem(
                  index: 3,
                  icon: Icons.account_circle_rounded,    // NEW
                  label: 'PROFILE',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xfff8f7ff) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: isActive ? const Color(0xFF008080) : const Color(0xff8b8b8b),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: isActive ? const Color(0xFF008080) : const Color(0xff8b8b8b),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

