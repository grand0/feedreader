import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webfeed/webfeed.dart';

import '../widgets/blur_clip_rect.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({Key? key, required RssItem item})
      : _item = item,
        super(key: key);

  final RssItem _item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              context: context,
              item: _item,
            ),
          ),
          SliverToBoxAdapter(
            child: Html(
              data: _item.content?.value ?? "<i>No content</i>",
              onLinkTap: (url, attributes, element) {
                if (url != null) {
                  launchUrlString(url, mode: LaunchMode.externalApplication);
                }
              },
              style: {
                "a": Style(
                  textDecoration: TextDecoration.none,
                )
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required BuildContext context,
    required RssItem item,
  })  : _context = context,
        _item = item;

  final BuildContext _context;
  final RssItem _item;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    return Stack(
      fit: StackFit.expand,
      children: [
        const BlurClipRect(),
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 8.0 * (1 - progress),
            left: 8.0 + 50 * Curves.easeOutCubic.transform(progress),
            right: 8.0 + 50 * Curves.easeOutCubic.transform(progress),
          ),
          alignment: Alignment.lerp(
              Alignment.bottomLeft, Alignment.center, progress),
          child: Text(
            _item.title ?? "Untitled",
            textAlign: TextAlign.start,
            style: TextStyle.lerp(
              Theme.of(context).textTheme.headlineSmall,
              Theme.of(context).textTheme.titleLarge,
              progress,
            ),
            overflow:
                progress < 0.05 ? TextOverflow.clip : TextOverflow.ellipsis,
          ),
        ),
        AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            if (_item.link != null)
              IconButton(
                icon: const Icon(Icons.open_in_browser),
                tooltip: "Open in browser",
                onPressed: () {
                  launchUrlString(_item.link!,
                      mode: LaunchMode.externalApplication);
                },
              ),
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent => minExtent + 100;

  @override
  double get minExtent =>
      AppBar().preferredSize.height + MediaQuery.of(_context).padding.top;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
