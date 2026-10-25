import 'package:flutter/material.dart';

import 'dashboard_icon.dart';

enum DashboardTab { vehicle, music, navigation, phone, apps, settings }

class BottomDock extends StatelessWidget {
  const BottomDock({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onVolume,
  });
  final DashboardTab? selected;
  final ValueChanged<DashboardTab> onSelect;
  final VoidCallback onVolume;
  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    color: Colors.black,
    child: Row(
      children: [
        const SizedBox(width: 12),
        for (final tab in DashboardTab.values)
          Expanded(
            child: Center(
              child: Semantics(
                selected: selected == tab,
                child: IconButton(
                  key: ValueKey('dock-${tab.name}'),
                  tooltip: tab.name[0].toUpperCase() + tab.name.substring(1),
                  onPressed: () => onSelect(tab),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: selected == tab
                        ? const Color(0xff272727)
                        : Colors.transparent,
                  ),
                  icon: switch (tab) {
                    DashboardTab.vehicle => const DashboardIcon(
                      'imgModel3Icon',
                    ),
                    DashboardTab.music => const DashboardIcon('imgMusic'),
                    DashboardTab.phone => const DashboardIcon('imgPhone'),
                    DashboardTab.navigation => const Icon(
                      Icons.near_me_outlined,
                      size: 23,
                    ),
                    DashboardTab.apps => const Icon(Icons.apps, size: 24),
                    DashboardTab.settings => const Icon(Icons.tune, size: 23),
                  },
                ),
              ),
            ),
          ),
        Expanded(
          child: IconButton(
            tooltip: 'Player volume',
            onPressed: onVolume,
            icon: const DashboardIcon('imgVolume'),
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
  );
}
