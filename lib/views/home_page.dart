import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './navigationpages/account_screen.dart';
import './navigationpages/booking_screen.dart';
import './navigationpages/expense_screen.dart';
import './navigationpages/home_screen.dart';
import './navigationpages/map_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = 'Account';
  String _photoUrl = '';

  final List<Widget> _pages = const [
    HomeScreen(),
    BookingScreen(),
    ExpenseScreen(),
    MapScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'Account';
      _photoUrl = prefs.getString('photoUrl') ?? '';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(
  IconData icon,
  String label,
  int index,
) {
  bool isSelected = _selectedIndex == index;

  // Helper to ensure all icons have same size
  Widget buildFixedSizeIcon(Widget child) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(child: child),
    );
  }

  // For Account tab
  if (index == 4) {
    return BottomNavigationBarItem(
      icon: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: _photoUrl.isNotEmpty
            ? buildFixedSizeIcon(
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(_photoUrl),
                ),
              )
            : buildFixedSizeIcon(const Icon(Icons.person, size: 24)),
      ),
      label: 'Account', // Always show "Account"
    );
  }

  // For other tabs
  return BottomNavigationBarItem(
    icon: AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: buildFixedSizeIcon(Icon(icon, size: 24)),
    ),
    label: label,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.black,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onTap: _onItemTapped,
        items: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.calendar_month, 'Booking', 1),
          _buildNavItem(Icons.attach_money, 'Expense', 2),
          _buildNavItem(Icons.location_on, 'Map', 3),
          _buildNavItem(Icons.person, 'Account', 4),
        ],
      ),
    );
  }
}
