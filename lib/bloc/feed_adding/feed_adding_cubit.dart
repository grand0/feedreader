import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:webfeed/domain/rss_feed.dart';

import '../../repositories/rss_repository.dart';

part 'feed_adding_state.dart';

class FeedAddingCubit extends Cubit<FeedAddingState> {
  FeedAddingCubit({required RssRepository rssRepo})
      : _rssRepository = rssRepo,
        super(const FeedAddingInitial(null));

  final RssRepository _rssRepository;

  void verifyAndGetFeed(Uri url) async {
    emit(FeedAddingVerifying(state.feed));

    await _rssRepository.getFeed(url).then(
          (feed) => emit(FeedAddingVerified(feed)),
          onError: (err) => emit(FeedAddingInitial(state.feed, err.toString())),
        );
  }

  void editUrl() {
    emit(FeedAddingInitial(state.feed));
  }
}
