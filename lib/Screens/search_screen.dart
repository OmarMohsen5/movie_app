import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/Providers/movie_provider.dart';
import 'package:movie_app/Widgets/state_widget.dart';
import 'package:movie_app/Screens/details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MovieProvider>().search(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = context.watch<MovieProvider>().searchResults;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_controller.text.isEmpty) {
            return const EmptyView(
              message: 'Start typing to search for movies',
              icon: Icons.search,
            );
          }
          if (results.isLoading) return const LoadingView();
          if (results.error != null) {
            return ErrorView(
              message: results.error!,
              onRetry: () =>
                  context.read<MovieProvider>().search(_controller.text),
            );
          }
          if (results.movies.isEmpty) {
            return const EmptyView(message: 'No movies found for that search');
          }
          return ListView.builder(
            itemCount: results.movies.length,
            itemBuilder: (context, index) {
              final movie = results.movies[index];
              return ListTile(
                leading: movie.posterUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          movie.posterUrl!,
                          width: 46,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.movie),
                title: Text(movie.title),
                subtitle: Text(movie.releaseDate),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(movieId: movie.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}