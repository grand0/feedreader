part of 'feed_list_bloc.dart';

@immutable
abstract class FeedListEvent {}

class FeedListAdd extends FeedListEvent {
  final Uri uri;

  FeedListAdd(this.uri);
}

class FeedListRefresh extends FeedListEvent {}
