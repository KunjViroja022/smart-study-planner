import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/subject_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/session_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/subject_management_screen.dart';
import 'screens/study_scheduling_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/search_filter_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectProvider()..loadSubjects()),
        ChangeNotifierProvider(create: (_) => TopicProvider()..loadTopics()),
        ChangeNotifierProvider(create: (_) => SessionProvider()..loadSessions()),
      ],
      child: MaterialApp(
        title: 'Smart Study Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigator(),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SubjectManagementScreen(),
    const StudySchedulingScreen(),
    const ProgressScreen(),
    const SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(child: _screens[_currentIndex]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withAlpha(26))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          ],
        ),
      ),
    );
  }
}
