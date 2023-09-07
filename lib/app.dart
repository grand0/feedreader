import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/feed_list/feed_list_bloc.dart';
import 'pages/home_page.dart';
import 'repositories/memory_repository.dart';
import 'repositories/rss_repository.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => RssRepository(),
        ),
        RepositoryProvider(
          create: (context) => MemoryRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => FeedListBloc(
          rssRepo: RepositoryProvider.of<RssRepository>(context),
          memoryRepo: RepositoryProvider.of<MemoryRepository>(context),
        )..add(FeedListRefresh()),
        child: DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) => AppView(
            lightColorScheme: lightColorScheme,
            darkColorScheme: darkColorScheme,
          ),
        ),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  })  : _lightColorScheme = lightColorScheme,
        _darkColorScheme = darkColorScheme,
        super(key: key);

  final ColorScheme? _lightColorScheme;
  final ColorScheme? _darkColorScheme;

  static final _defaultLightColorScheme =
      ColorScheme.fromSeed(seedColor: Colors.deepPurple);
  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Feedreader",
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme ?? _defaultLightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme ?? _defaultDarkColorScheme,
      ),
    );
  }
}
