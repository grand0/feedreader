part of 'feed_adding_cubit.dart';

@immutable
abstract class FeedAddingState {
  const FeedAddingState(this.feed);

  final RssFeed? feed;
}

class FeedAddingInitial extends FeedAddingState {
  const FeedAddingInitial(super.feed, [this.error]);

  final String? error;
}

class FeedAddingVerifying extends FeedAddingState {
  const FeedAddingVerifying(super.feed);
}

class FeedAddingVerified extends FeedAddingState {
  const FeedAddingVerified(super.feed);
}
