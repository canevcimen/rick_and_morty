import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';
import 'character_detail_screen.dart';
import 'package:rick_and_morty/screens/detail_screen.dart';


class FavoritesScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Episodes and Characters'),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favoriteEpisodes = favoritesProvider.favoriteEpisodes;
          final favoriteCharacters = favoritesProvider.favoriteCharacters;

          if (favoriteEpisodes.isEmpty && favoriteCharacters.isEmpty) {
            return Center(child: Text('No favorites yet.'));
          }

          return ListView(
            children: [
              if (favoriteEpisodes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Favorite Episodes',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ...favoriteEpisodes.map((episodeId) {
                return FutureBuilder(
                  future: apiService.fetchEpisodeDetails(episodeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final episode = snapshot.data!;
                      return ListTile(
                        title: Text(episode['name']),
                        subtitle: Text('Episode ${episode['episode']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Remove Favorite'),
                                content: Text(
                                    'Are you sure you want to remove ${episode['name']} from favorites?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      favoritesProvider.toggleFavoriteEpisode(episodeId);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EpisodeDetailScreen(
                                episodeId: episode['id'],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }).toList(),
              if (favoriteCharacters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Favorite Characters',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ...favoriteCharacters.map((characterId) {
                return FutureBuilder(
                  future: apiService.fetchCharacterDetails(characterId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final character = snapshot.data!;
                      return ListTile(
                        title: Text(character['name']),
                        subtitle: Text(character['species']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Remove Favorite'),
                                content: Text(
                                    'Are you sure you want to remove ${character['name']} from favorites?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      favoritesProvider.toggleFavoriteCharacter(characterId);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CharacterDetailScreen(
                                characterId: character['id'],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
