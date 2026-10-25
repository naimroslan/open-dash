import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardIcon extends StatelessWidget {
  const DashboardIcon(this.asset, {super.key, this.size = 24, this.color});
  final String asset;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: SvgPicture.asset(
      'assets/icons/$asset.svg',
      fit: BoxFit.contain,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    ),
  );
}
