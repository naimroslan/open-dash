import 'package:flutter/material.dart';

const accent = Color(0xffd43b43);
ThemeData dashboardTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: dark
        ? const Color(0xff0e0e0e)
        : const Color(0xfff3f4f5),
    colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: brightness)
        .copyWith(
          primary: accent,
          surface: dark ? const Color(0xff171717) : Colors.white,
        ),
    dividerColor: dark ? const Color(0xff343434) : const Color(0xffd8dade),
    textTheme: ThemeData(
      brightness: brightness,
    ).textTheme.apply(fontFamily: 'Montserrat'),
    fontFamily: 'Montserrat',
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 2,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}
