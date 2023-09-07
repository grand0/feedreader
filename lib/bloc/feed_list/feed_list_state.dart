part of 'feed_list_bloc.dart';

@immutable
abstract class FeedListState {
  final List<RssFeed> feeds;

  const FeedListState(this.feeds);
}

class FeedListReady extends FeedListState {
  const FeedListReady(super.feeds);
}

class FeedListLoading extends FeedListState {
  const FeedListLoading(super.feeds);
}

class FeedListError extends FeedListState {
  final String? error;

  const FeedListError(super.feeds, [this.error]);
}
