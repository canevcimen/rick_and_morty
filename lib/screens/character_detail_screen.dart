import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CharacterDetailScreen extends StatelessWidget {
  final int characterId;

  CharacterDetailScreen({required this.characterId});

  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Character Details'),
      ),
      body: FutureBuilder(
        future: apiService.fetchCharacterDetails(characterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final character = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  title: Text(character['name']),
                  subtitle: Text('Status: ${character['status']}'),
                ),
                ListTile(
                  title: Text('Species: ${character['species']}'),
                ),
                ListTile(
                  title: Text('Gender: ${character['gender']}'),
                ),
                ListTile(
                  title: Text('Origin: ${character['origin']['name']}'),
                ),
                ListTile(
                  title: Text('Location: ${character['location']['name']}'),
                ),
                Image.network(character['image']),
              ],
            );
          }
        },
      ),
    );
  }
}
