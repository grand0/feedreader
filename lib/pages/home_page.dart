import 'package:feedreader/pages/add_feed_page.dart';
import 'package:feedreader/pages/feed_page.dart';
import 'package:feedreader/widgets/feed_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webfeed/webfeed.dart';

import '../bloc/feed_list/feed_list_bloc.dart';
import '../widgets/blur_clip_rect.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedreader"),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).colorScheme.background.withOpacity(0.8),
        flexibleSpace: const BlurClipRect(),
      ),
      body: BlocBuilder<FeedListBloc, FeedListState>(
        builder: (context, state) {
          if (state is FeedListReady) {
            return FeedListView(state.feeds);
          } else if (state is FeedListLoading) {
            return const LoadingView();
          } else if (state is FeedListError) {
            return ErrorView(state.error);
          } else {
            return ErrorView("No view for this state: ${state.runtimeType}");
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddFeedPage()),
          );
        },
      ),
    );
  }
}

class AddFeedDialog extends StatefulWidget {
  const AddFeedDialog({Key? key}) : super(key: key);

  @override
  State<AddFeedDialog> createState() => _AddFeedDialogState();
}

class _AddFeedDialogState extends State<AddFeedDialog> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text("Add feed"),
      content: AddFeedForm(),
    );
  }
}

class AddFeedForm extends StatefulWidget {
  const AddFeedForm({Key? key}) : super(key: key);

  @override
  State<AddFeedForm> createState() => _AddFeedFormState();
}

class _AddFeedFormState extends State<AddFeedForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "URL",
            ),
            validator: (val) {
              if (val == null || val.isEmpty || Uri.tryParse(val) == null) {
                return "Enter valid URL";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, Uri.parse(_urlController.text));
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedListView extends StatelessWidget {
  FeedListView(this.feeds, {Key? key}) : super(key: key);

  final List<RssFeed> feeds;
  final _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedListBloc, FeedListState>(
      listenWhen: (prev, cur) {
        return prev is FeedListLoading;
      },
      listener: (context, state) {
        if (state is FeedListReady) {
          _refreshController.refreshCompleted();
        } else if (state is FeedListError) {
          _refreshController.refreshFailed();
        }
      },
      child: SmartRefresher(
        controller: _refreshController,
        header: const MaterialClassicHeader(),
        onRefresh: () => context.read<FeedListBloc>().add(FeedListRefresh()),
        child: ListView(
          children: feeds.map((feed) => FeedCard(feed)).toList(),
        ),
      ),
    );
  }
}

class FeedCard extends StatelessWidget {
  const FeedCard(this.feed, {Key? key}) : super(key: key);

  final RssFeed feed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: FeedImageOrIcon(feed: feed, width: 40),
        title: Text(feed.title ?? "Untitled"),
        subtitle: feed.items != null && feed.items!.isNotEmpty
            ? Text("Latest post: ${feed.items!.first.title ?? "Untitled"}")
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeedPage(feed: feed)),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView(this.error, {Key? key}) : super(key: key);

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning),
          const Text("Error"),
          if (error != null) Text(error!),
        ],
      ),
    );
  }
}
