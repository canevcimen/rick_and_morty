import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  Future<Map<String, dynamic>> fetchEpisodes(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/episode?page=$page'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  Future<Map<String, dynamic>> fetchEpisodeDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/episode/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load episode details');
    }
  }

  Future<Map<String, dynamic>> fetchCharacterDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/character/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load character details');
    }
  }

  Future<Map<String, dynamic>> fetchCharacters(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/character?page=$page'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load characters');
    }
  }
}
