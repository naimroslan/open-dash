import 'package:flutter/material.dart';

import '../../widgets/dashboard_icon.dart';
import 'media_controller.dart';

class MediaStrip extends StatelessWidget {
  const MediaStrip({super.key, required this.media, required this.onExpand});
  final DashboardMedia media;
  final VoidCallback onExpand;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: media,
    builder: (context, _) => Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(5),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            InkWell(
              onTap: onExpand,
              child: Container(
                width: 74,
                height: 80,
                color: const Color(0xff28313f),
                child: const Icon(
                  Icons.graphic_eq,
                  color: Colors.white70,
                  size: 34,
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onExpand,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        media.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        media.error ?? 'Original demo audio',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: media.duration.inMilliseconds > 0
                            ? media.position.inMilliseconds /
                                  media.duration.inMilliseconds
                            : 0,
                        minHeight: 2,
                        color: Colors.white54,
                        backgroundColor: Colors.white12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Previous track',
              onPressed: media.previous,
              icon: const DashboardIcon('imgPrevtrack', size: 22),
            ),
            IconButton(
              tooltip: media.playing ? 'Pause audio' : 'Play audio',
              onPressed: media.toggle,
              icon: media.playing
                  ? const DashboardIcon('imgPause', size: 22)
                  : const Icon(Icons.play_arrow, size: 27),
            ),
            IconButton(
              tooltip: 'Next track',
              onPressed: media.next,
              icon: const DashboardIcon('imgNexttrack', size: 22),
            ),
            IconButton(
              tooltip: 'Expand media',
              onPressed: onExpand,
              icon: const DashboardIcon('imgExpandMusic', size: 23),
            ),
          ],
        ),
      ),
    ),
  );
}
