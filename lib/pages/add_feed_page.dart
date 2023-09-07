import 'package:feedreader/bloc/feed_adding/feed_adding_cubit.dart';
import 'package:feedreader/repositories/rss_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webfeed/webfeed.dart';

import '../bloc/feed_list/feed_list_bloc.dart';

class AddFeedPage extends StatelessWidget {
  AddFeedPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedAddingCubit(
        rssRepo: RepositoryProvider.of<RssRepository>(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Add feed"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<FeedAddingCubit, FeedAddingState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UrlForm(
                      formKey: _formKey,
                      urlController: _urlController,
                      enabled: state is FeedAddingInitial ||
                          state is FeedAddingVerified,
                      readOnly: state is FeedAddingVerified,
                    ),
                    AnimatedCrossFade(
                      firstChild: Container(),
                      secondChild: state.feed != null
                          ? FeedPreview(feed: state.feed!)
                          : Container(),
                      crossFadeState: state is FeedAddingVerified
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                      firstCurve: Curves.ease,
                      secondCurve: Curves.ease,
                    )
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: BlocConsumer<FeedAddingCubit, FeedAddingState>(
          builder: (context, state) {
            if (state is FeedAddingInitial) {
              return _buildFabNext(context);
            }
            if (state is FeedAddingVerifying) {
              return _buildFabLoading(context);
            }
            if (state is FeedAddingVerified) {
              return _buildFabComplete(context);
            }
            return Container();
          },
          listenWhen: (prev, cur) =>
              prev is FeedAddingVerifying && cur is FeedAddingInitial,
          listener: (context, state) {
            const snackbar = SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error),
                  SizedBox(width: 16),
                  Text("No RSS feed was found at this URL."),
                ],
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildFabNext(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.navigate_next),
      label: const Text("Next"),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context
              .read<FeedAddingCubit>()
              .verifyAndGetFeed(Uri.parse(_urlController.text));
        }
      },
    );
  }

  Widget _buildFabLoading(BuildContext context) {
    return FloatingActionButton(
      onPressed: null,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildFabComplete(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.done),
      label: const Text("Add"),
      onPressed: () {
        context
            .read<FeedListBloc>()
            .add(FeedListAdd(Uri.parse(_urlController.text)));
        Navigator.pop(context);
      },
    );
  }
}

class UrlForm extends StatelessWidget {
  const UrlForm({
    Key? key,
    required GlobalKey<FormState> formKey,
    required TextEditingController urlController,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
  })  : _autofocus = autofocus,
        _readOnly = readOnly,
        _enabled = enabled,
        _formKey = formKey,
        _urlController = urlController,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final TextEditingController _urlController;
  final bool _enabled;
  final bool _readOnly;
  final bool _autofocus;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        readOnly: _readOnly,
        enabled: _enabled,
        autofocus: _autofocus,
        controller: _urlController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: "RSS URL",
          suffixIcon: _readOnly
              ? IconButton(
                  onPressed: () => context.read<FeedAddingCubit>().editUrl(),
                  icon: const Icon(Icons.edit),
                )
              : null,
        ),
        validator: (text) {
          if (text == null || text.isEmpty || Uri.tryParse(text) == null) {
            return "Enter valid URL";
          }
          return null;
        },
      ),
    );
  }
}

class FeedPreview extends StatelessWidget {
  const FeedPreview({Key? key, required this.feed}) : super(key: key);

  final RssFeed feed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        feed.image != null && feed.image?.url != null
            ? Image.network(
                feed.image!.url!,
                fit: BoxFit.fitHeight,
                width: 75,
                errorBuilder: (_, __, ___) => const Icon(Icons.feed, size: 30),
              )
            : const Icon(Icons.feed, size: 75),
        const SizedBox(height: 16),
        Text(
          feed.title ?? "Untitled",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          feed.description ?? "No description",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontStyle:
                feed.description == null ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
