import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'character_detail_screen.dart';
import '../providers/favorites_provider.dart';

class EpisodeDetailScreen extends StatelessWidget {
  final int episodeId;

  EpisodeDetailScreen({required this.episodeId});

  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Episode Details'),
      ),
      body: FutureBuilder(
        future: apiService.fetchEpisodeDetails(episodeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final episode = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  title: Text(episode['name']),
                  subtitle: Text('Air date: ${episode['air_date']}'),
                ),
                ...episode['characters'].map((characterUrl) {
                  final characterId = int.parse(characterUrl.split('/').last);
                  return ListTile(
                    title: Text('Character $characterId'),
                    trailing: IconButton(
                      icon: Icon(
                        Provider.of<FavoritesProvider>(context)
                            .favoriteCharacters
                            .contains(characterId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      onPressed: () {
                        Provider.of<FavoritesProvider>(context, listen: false)
                            .toggleFavoriteCharacter(characterId);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CharacterDetailScreen(
                            characterId: characterId,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            );
          }
        },
      ),
    );
  }
}
