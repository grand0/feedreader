import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';

class RssRepository {
  List<Future<RssFeed>> getFeeds(List<Uri> uris) {
    return uris.map((uri) => getFeed(uri)).toList();
  }

  Future<RssFeed> getFeed(Uri url) async {
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      return RssFeed.parse(resp.body);
    } else {
      return Future.error("Error (${resp.statusCode})");
    }
  }
}