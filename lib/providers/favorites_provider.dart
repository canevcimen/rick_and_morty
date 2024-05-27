import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  List<int> _favoriteEpisodes = [];
  List<int> _favoriteCharacters = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FavoritesProvider() {
    _initializeNotifications();
    loadFavorites();
  }

  List<int> get favoriteEpisodes => _favoriteEpisodes;
  List<int> get favoriteCharacters => _favoriteCharacters;

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Favori Karakter Sınırı',
      'Favori karakter ekleme sayısını aştınız. Başka bir karakteri favorilerden çıkarmalısınız.',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void toggleFavoriteEpisode(int episodeId) {
    if (_favoriteEpisodes.contains(episodeId)) {
      _favoriteEpisodes.remove(episodeId);
    } else {
      _favoriteEpisodes.add(episodeId);
    }
    notifyListeners();
    saveFavorites();
  }

  void toggleFavoriteCharacter(int characterId) {
    if (_favoriteCharacters.contains(characterId)) {
      _favoriteCharacters.remove(characterId);
    } else {
      if (_favoriteCharacters.length >= 10) {
        _showNotification();
      } else {
        _favoriteCharacters.add(characterId);
      }
    }
    notifyListeners();
    saveFavorites();
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteEpisodeIds = prefs.getStringList('favoriteEpisodes');
    List<String>? favoriteCharacterIds = prefs.getStringList('favoriteCharacters');
    if (favoriteEpisodeIds != null) {
      _favoriteEpisodes = favoriteEpisodeIds.map((id) => int.parse(id)).toList();
    }
    if (favoriteCharacterIds != null) {
      _favoriteCharacters = favoriteCharacterIds.map((id) => int.parse(id)).toList();
    }
    notifyListeners();
  }

  void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'favoriteEpisodes',
      _favoriteEpisodes.map((id) => id.toString()).toList(),
    );
    prefs.setStringList(
      'favoriteCharacters',
      _favoriteCharacters.map((id) => id.toString()).toList(),
    );
  }
}
