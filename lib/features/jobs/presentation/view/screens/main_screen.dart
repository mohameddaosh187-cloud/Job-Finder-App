import 'package:flutter/material.dart';

import '../../../data/api/job_api.dart';
import '../../view_model/home_cubit.dart';

import '../../../../profile/presentation/view/screens/profile_screen.dart';
import '../../../../profile/presentation/view/screens/saved_jobs_screen.dart';

import 'home_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _savedJobsRefreshKey = 0;
  int _profileRefreshKey = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(
        createCubit: () => HomeCubit(JobApi()),
      ),
      const SearchScreen(),
      const SavedJobsScreen(
        showBackButton: false,
      ),
      ProfileScreen(
        key: ValueKey(_profileRefreshKey),
      ),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 2) {
        _savedJobsRefreshKey++;

        _screens[2] = SavedJobsScreen(
          key: ValueKey(_savedJobsRefreshKey),
          showBackButton: false,
        );
      }

      if (index == 3) {
        _profileRefreshKey++;

        _screens[3] = ProfileScreen(
          key: ValueKey(_profileRefreshKey),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}