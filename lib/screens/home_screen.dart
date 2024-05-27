import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';
import 'character_detail_screen.dart';
import 'package:rick_and_morty/screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  int _currentPage = 1;
  List _episodes = [];
  List _characters = [];
  List _filteredItems = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_searchItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchItems);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final episodeData = await apiService.fetchEpisodes(_currentPage);
      final characterData = await apiService.fetchCharacters(_currentPage);
      setState(() {
        _episodes.addAll(episodeData['results']);
        _characters.addAll(characterData['results']);
        _filteredItems = [..._episodes, ..._characters];
      });
    } catch (e) {
      // handle error
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = [
        ..._episodes.where((episode) {
          return episode['name'].toLowerCase().contains(query) ||
              episode['episode'].toLowerCase().contains(query);
        }).toList(),
        ..._characters.where((character) {
          return character['name'].toLowerCase().contains(query);
        }).toList(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rick & Morty Episodes and Characters'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Image.asset('images/rick_and_morty_logo.png',height: 200,width: double.infinity,fit: BoxFit.contain,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search episodes or characters...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isEpisode = item.containsKey('episode');
                if (isEpisode) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      title: Text(item['name']),
                      subtitle: Text('Episode ${item['episode']}'),
                      trailing: IconButton(
                        icon: Icon(
                          Provider.of<FavoritesProvider>(context)
                              .favoriteEpisodes
                              .contains(item['id'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        onPressed: () {
                          Provider.of<FavoritesProvider>(context,
                              listen: false)
                              .toggleFavoriteEpisode(item['id']);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EpisodeDetailScreen(
                              episodeId: item['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      title: Text(item['name']),
                      subtitle: Text(item['species']),
                      trailing: IconButton(
                        icon: Icon(
                          Provider.of<FavoritesProvider>(context)
                              .favoriteCharacters
                              .contains(item['id'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        onPressed: () {
                          Provider.of<FavoritesProvider>(context,
                              listen: false)
                              .toggleFavoriteCharacter(item['id']);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CharacterDetailScreen(
                              characterId: item['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),

    );
  }
}
