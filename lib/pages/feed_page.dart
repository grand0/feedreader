import 'package:feedreader/pages/item_page.dart';
import 'package:feedreader/widgets/feed_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';

import '../widgets/blur_clip_rect.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key, required RssFeed feed})
      : _feed = feed,
        super(key: key);

  final RssFeed _feed;

  @override
  Widget build(BuildContext context) {
    final provider =
        _feed.image?.url != null ? NetworkImage(_feed.image!.url!) : null;

    return FutureBuilder(
      future: _getPaletteGenerator(provider),
      builder: (context, snapshot) {
        final scaffold = Scaffold(
          body: _FeedView(feed: _feed),
        );
        if (snapshot.hasData && snapshot.data != null) {
          final PaletteGenerator palette = snapshot.data!;
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    surfaceTint: palette.dominantColor?.color,
                  ),
            ),
            child: scaffold,
          );
        }
        return scaffold;
      },
    );
  }

  Future<PaletteGenerator?> _getPaletteGenerator(
      ImageProvider? provider) async {
    if (provider != null) {
      final paletteGenerator =
          await PaletteGenerator.fromImageProvider(provider);
      return paletteGenerator;
    } else {
      return null;
    }
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView({Key? key, required RssFeed feed})
      : _feed = feed,
        super(key: key);

  final RssFeed _feed;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _HeaderDelegate(context: context, feed: _feed),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (_feed.items == null) {
                return Container();
              }
              return _FeedItemCard(item: _feed.items![index]);
            },
            childCount: _feed.items?.length ?? 0,
          ),
        ),
      ],
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required BuildContext context,
    required RssFeed feed,
  })  : _context = context,
        _feed = feed;

  final BuildContext _context;
  final RssFeed _feed;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    return Stack(
      fit: StackFit.expand,
      children: [
        const BlurClipRect(),
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Opacity(
            opacity: 1 - progress,
            child: FeedImageOrIcon(
              feed: _feed,
              width: 100,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 8.0 * (1 - progress),
            left: 8.0 + 50 * Curves.easeOutCubic.transform(progress),
            right: 8.0 + 50 * Curves.easeOutCubic.transform(progress),
          ),
          alignment: Alignment.lerp(
              Alignment.bottomCenter, Alignment.center, progress),
          child: Text(
            _feed.title ?? "Untitled",
            textAlign: TextAlign.center,
            style: TextStyle.lerp(
              Theme.of(context).textTheme.headlineLarge,
              Theme.of(context).textTheme.titleLarge,
              progress,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppBar(
          backgroundColor: Colors.transparent,
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

class _FeedItemCard extends StatelessWidget {
  const _FeedItemCard({
    Key? key,
    required RssItem item,
  })  : _item = item,
        super(key: key);

  final RssItem _item;

  @override
  Widget build(BuildContext context) {
    final dateStr = _item.pubDate != null
        ? DateFormat.yMd().add_jm().format(_item.pubDate!)
        : null;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ItemPage(item: _item))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dateStr != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ListTile(
                title: Text(_item.title ?? "Untitled"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
