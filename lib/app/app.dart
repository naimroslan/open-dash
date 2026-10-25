import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/dashboard/dashboard_screen.dart';
import 'theme.dart';

class CityApp extends StatefulWidget {
  const CityApp({super.key});
  @override
  State<CityApp> createState() => _CityAppState();
}

class _CityAppState extends State<CityApp> {
  bool _dark = true;
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _dark = prefs.getBool('dark') ?? true);
  }

  Future<void> _setTheme(bool value) async {
    setState(() => _dark = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark', value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'City Dashboard',
    debugShowCheckedModeBanner: false,
    theme: dashboardTheme(Brightness.light),
    darkTheme: dashboardTheme(Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    home: DashboardScreen(dark: _dark, onThemeChanged: _setTheme),
  );
}
