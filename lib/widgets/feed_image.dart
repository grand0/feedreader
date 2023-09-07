import 'package:flutter/material.dart';
import 'package:webfeed/domain/rss_feed.dart';

class FeedImageOrIcon extends StatelessWidget {
  const FeedImageOrIcon({
    Key? key,
    required RssFeed feed,
    double? width,
    double? height,
    EdgeInsets? padding,
  })  : _feed = feed,
        _width = width,
        _height = height,
        _padding = padding,
        super(key: key);

  final RssFeed _feed;
  final double? _width;
  final double? _height;
  final EdgeInsets? _padding;

  @override
  Widget build(BuildContext context) {
    return _feed.image?.url != null
        ? Container(
            width: _width,
            height: _height,
            padding: _padding,
            child: Image.network(
              _feed.image!.url!,
              // width: _width,
              // height: _height,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildDefaultFeedIcon(),
            ),
          )
        : _buildDefaultFeedIcon();
  }

  Widget _buildDefaultFeedIcon() => FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: _padding ?? EdgeInsets.zero,
          child: Icon(Icons.feed, size: _width),
        ),
      );
}
