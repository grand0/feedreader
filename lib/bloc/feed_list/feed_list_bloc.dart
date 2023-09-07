import 'package:bloc/bloc.dart';
import 'package:feedreader/repositories/memory_repository.dart';
import 'package:feedreader/repositories/rss_repository.dart';
import 'package:meta/meta.dart';
import 'package:webfeed/webfeed.dart';

part 'feed_list_event.dart';
part 'feed_list_state.dart';

class FeedListBloc extends Bloc<FeedListEvent, FeedListState> {
  FeedListBloc({
    required RssRepository rssRepo,
    required MemoryRepository memoryRepo,
  })  : _rssRepository = rssRepo,
        _memoryRepository = memoryRepo,
        super(const FeedListReady([])) {
    on<FeedListAdd>(_onAdd);
    on<FeedListRefresh>(_onRefresh);
  }

  final RssRepository _rssRepository;
  final MemoryRepository _memoryRepository;

  Future<void> _onAdd(FeedListAdd event, Emitter<FeedListState> emit) async {
    emit(FeedListLoading(state.feeds));

    await _memoryRepository.addFeedUrl(event.uri);
    await _rssRepository.getFeed(event.uri).then(
          (feed) => emit(FeedListReady(state.feeds + [feed])),
          onError: (err) => emit(FeedListError(state.feeds, err.toString())),
        );
  }

  void _onRefresh(FeedListRefresh event, Emitter<FeedListState> emit) async {
    emit(FeedListLoading(state.feeds));

    final urls = await _memoryRepository.getFeedsUrls();

    final feeds = <RssFeed>[];
    for (final Future<RssFeed> fut in _rssRepository.getFeeds(urls)) {
      final feed = await fut.onError((err, _) => RssFeed(title: err.toString()));
      feeds.add(feed);
    }
    emit(FeedListReady(feeds));
    // await _rssRepository.getFeeds(urls).then(
    //       (feeds) => emit(FeedListReady(feeds)),
    //       onError: (err) => emit(FeedListError(state.feeds, err.toString())),
    //     );
  }
}
