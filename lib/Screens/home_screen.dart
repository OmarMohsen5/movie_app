import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/Models/movie.dart';
import 'package:movie_app/Providers/movie_provider.dart';
import 'package:movie_app/Providers/auth_provider.dart';
import 'package:movie_app/Widgets/state_widget.dart';
import 'package:movie_app/Screens/details_screen.dart';
import 'package:movie_app/Screens/search_screen.dart';
import 'package:movie_app/Screens/lists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const MyListsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<MovieProvider>().loadHome(),
        child: ListView(
          children: [
            _Section(title: 'Popular', section: movies.popular),
            _Section(title: 'Top Rated', section: movies.topRated),
            _Section(title: 'Now Playing', section: movies.nowPlaying),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final MovieSection section;
  const _Section({required this.title, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: Builder(
              builder: (context) {
                if (section.isLoading && section.movies.isEmpty) {
                  return const LoadingView();
                }
                if (section.error != null) {
                  return ErrorView(
                    message: section.error!,
                    onRetry: () => context.read<MovieProvider>().loadHome(),
                  );
                }
                if (section.movies.isEmpty) {
                  return const EmptyView(message: 'No movies found');
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: section.movies.length,
                  itemBuilder: (context, index) =>
                      _MovieCard(movie: section.movies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailsScreen(movieId: movie.id)),
      ),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterUrl != null
                  ? Image.network(
                      movie.posterUrl!,
                      height: 180,
                      width: 130,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null ? child : const LoadingView(),
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 48),
                    )
                  : Container(
                      height: 180,
                      width: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie),
                    ),
            ),
            const SizedBox(height: 4),
            Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}