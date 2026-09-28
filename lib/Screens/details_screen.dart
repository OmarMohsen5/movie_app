import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/Models/movie.dart';
import 'package:movie_app/Models/movie_list_item.dart';
import 'package:movie_app/Providers/movie_provider.dart';
import 'package:movie_app/Providers/list_provider.dart';
import 'package:movie_app/Widgets/state_widget.dart';

class DetailsScreen extends StatefulWidget {
  final int movieId;
  const DetailsScreen({super.key, required this.movieId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<Movie> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<MovieProvider>().loadDetails(widget.movieId);
    _future.then((movie) {
      if (mounted) context.read<ListProvider>().refreshStatus(movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Movie>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {
                _future = context.read<MovieProvider>().loadDetails(
                  widget.movieId,
                );
              }),
            );
          }
          final movie = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: movie.backdropUrl != null
                      ? Image.network(
                          movie.backdropUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[400]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(' ${movie.voteAverage.toStringAsFixed(1)}'),
                          const SizedBox(width: 16),
                          Text(movie.releaseDate),
                          if (movie.runtime != null) ...[
                            const SizedBox(width: 16),
                            Text('${movie.runtime} min'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          _ToggleChip(
                            movie: movie,
                            type: ListType.favorite,
                            label: 'Favorite',
                            icon: Icons.favorite,
                          ),
                          _ToggleChip(
                            movie: movie,
                            type: ListType.watched,
                            label: 'Watched',
                            icon: Icons.check_circle,
                          ),
                          _ToggleChip(
                            movie: movie,
                            type: ListType.watching,
                            label: 'Watching',
                            icon: Icons.play_circle,
                          ),
                          _ToggleChip(
                            movie: movie,
                            type: ListType.wantToWatch,
                            label: 'Want to Watch',
                            icon: Icons.bookmark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(movie.overview),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final Movie movie;
  final ListType type;
  final String label;
  final IconData icon;
  const _ToggleChip({
    required this.movie,
    required this.type,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();
    final isActive = listProvider.currentMovieStatus[type] ?? false;

    return FilterChip(
      avatar: Icon(icon, size: 18, color: isActive ? Colors.white : null),
      label: Text(label),
      selected: isActive,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(color: isActive ? Colors.white : null),
      onSelected: (_) => context.read<ListProvider>().toggle(movie, type),
    );
  }
}