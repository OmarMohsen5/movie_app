import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/Models/movie_list_item.dart';
import 'package:movie_app/Providers/list_provider.dart';
import 'package:movie_app/Widgets/state_widget.dart';
import 'details_screen.dart';

class MyListsScreen extends StatelessWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Lists'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Watched'),
              Tab(text: 'Watching'),
              Tab(text: 'Want to Watch'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListTab(type: ListType.favorite, emptyMessage: 'No favorites yet'),
            _ListTab(
              type: ListType.watched,
              emptyMessage: 'You haven\'t marked anything as watched',
            ),
            _ListTab(
              type: ListType.watching,
              emptyMessage: 'Nothing in progress right now',
            ),
            _ListTab(
              type: ListType.wantToWatch,
              emptyMessage: 'Your watch-list is empty',
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  final ListType type;
  final String emptyMessage;
  const _ListTab({required this.type, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();

    return FutureBuilder<List<MovieListItem>>(
      future: listProvider.getList(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          print('List Error for \(type:\){snapshot.error}'); 
          return ErrorView(message: 'Error: ${snapshot.error}');
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return EmptyView(message: emptyMessage);
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final posterUrl = item.posterPath == null
                ? null
                : 'https://image.tmdb.org/t/p/w200${item.posterPath}';
            return ListTile(
              leading: posterUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        posterUrl,
                        width: 46,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.movie),
              title: Text(item.title),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailsScreen(movieId: item.movieId),
                ),
              ),
            );
          },
        );
      },
    );
  }
}