import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_room.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _kStorageKey = 'favorite_rooms';

    final List<FavoriteRoom> _rooms = [];
      List<FavoriteRoom> get rooms => List.unmodifiable(_rooms);

        Future<void> load() async {
            final prefs = await SharedPreferences.getInstance();
                final raw = prefs.getString(_kStorageKey);
                    if (raw != null) {
                          final List<dynamic> decoded = jsonDecode(raw);
                                _rooms
                                        ..clear()
                                                ..addAll(decoded.map((e) => FavoriteRoom.fromJson(e)));
                                                    }
                                                        notifyListeners();
                                                          }

                                                            Future<void> _persist() async {
                                                                final prefs = await SharedPreferences.getInstance();
                                                                    final raw = jsonEncode(_rooms.map((r) => r.toJson()).toList());
                                                                        await prefs.setString(_kStorageKey, raw);
                                                                          }

                                                                            Future<void> add(String name, String url) async {
                                                                                _rooms.add(
                                                                                      FavoriteRoom(
                                                                                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                                                                                                      name: name,
                                                                                                              url: url,
                                                                                                                      addedAt: DateTime.now(),
                                                                                                                            ),
                                                                                                                                );
                                                                                                                                    await _persist();
                                                                                                                                        notifyListeners();
                                                                                                                                          }

                                                                                                                                            Future<void> remove(String id) async {
                                                                                                                                                _rooms.removeWhere((r) => r.id == id);
                                                                                                                                                    await _persist();
                                                                                                                                                        notifyListeners();
                                                                                                                                                          }
                                                                                                                                                          }