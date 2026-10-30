import 'package:flutter/material.dart';

import 'package:job_finder/core/theme/locale_controller.dart';

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

  late List<Widget> _screens;

  static const Color _primaryBlue = Color(0xFF385CF2);

  bool get _isArabic => LocaleController.instance.locale.languageCode == 'ar';

  String _text(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(createCubit: () => HomeCubit(JobApi())),
      const SearchScreen(),
      const SavedJobsScreen(showBackButton: false),
      ProfileScreen(key: ValueKey(_profileRefreshKey)),
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

        _screens[3] = ProfileScreen(key: ValueKey(_profileRefreshKey));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleController.instance,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        final navigationBackground = isDark
            ? const Color(0xFF171B24)
            : Colors.white;

        final selectedIndicator = isDark
            ? const Color(0xFF293A75)
            : const Color(0xFFE3EBFF);

        return Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: IndexedStack(index: _selectedIndex, children: _screens),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: navigationBackground,
                indicatorColor: selectedIndicator,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                  states,
                ) {
                  final selected = states.contains(WidgetState.selected);

                  return TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _primaryBlue : colors.onSurfaceVariant,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((
                  states,
                ) {
                  final selected = states.contains(WidgetState.selected);

                  return IconThemeData(
                    color: selected ? _primaryBlue : colors.onSurfaceVariant,
                    size: 24,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onDestinationSelected,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: _text('Home', 'الرئيسية'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.search_outlined),
                    selectedIcon: const Icon(Icons.search),
                    label: _text('Search', 'البحث'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.bookmark_border_rounded),
                    selectedIcon: const Icon(Icons.bookmark_rounded),
                    label: _text('Saved', 'المحفوظات'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: _text('Profile', 'الملف الشخصي'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
