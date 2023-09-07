import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MemoryRepository {
  static const _rssUrlsFileName = "urls";

  Future<List<Uri>> getFeedsUrls() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File.fromUri(dir.uri.resolve(_rssUrlsFileName));
    if (!(await file.exists())) {
      return <Uri>[];
    }
    final lines = await file.readAsLines();
    return lines.where((s) => s.isNotEmpty).map((s) => Uri.parse(s)).toList();
  }

  Future<void> addFeedUrl(Uri url) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File.fromUri(dir.uri.resolve(_rssUrlsFileName));
    if (!(await file.exists())) {
      await file.create();
    }
    await file.writeAsString(
      "${url.toString()}\n",
      mode: FileMode.append,
      flush: true,
    );
  }
}
