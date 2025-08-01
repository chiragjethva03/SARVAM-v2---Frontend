import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

import 'navigationpages/account/account_screen.dart';
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

  final List<Widget> _pages = const [
    HomeScreen(),
    BookingScreen(),
    ExpenseScreen(),
    MapScreen(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final userProvider = Provider.of<UserProvider>(context);
    final photoUrl = userProvider.profilePicture ?? '';
    bool isSelected = _selectedIndex == index;

    Widget buildFixedSizeIcon(Widget child) {
      return SizedBox(
        width: 24,
        height: 24,
        child: Center(child: child),
      );
    }

    // Account Tab
    if (index == 4) {
      return BottomNavigationBarItem(
        icon: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: photoUrl.isNotEmpty
              ? buildFixedSizeIcon(
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                )
              : buildFixedSizeIcon(const Icon(Icons.person, size: 24)),
        ),
        label: 'Account',
      );
    }

    // Other Tabs
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
          _buildNavItem(context, Icons.home, 'Home', 0),
          _buildNavItem(context, Icons.calendar_month, 'Booking', 1),
          _buildNavItem(context, Icons.attach_money, 'Expense', 2),
          _buildNavItem(context, Icons.location_on, 'Map', 3),
          _buildNavItem(context, Icons.person, 'Account', 4),
        ],
      ),
    );
  }
}
