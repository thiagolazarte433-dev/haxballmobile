class FavoriteRoom {
  final String id;
  final String name;
  final String url;
  final DateTime addedAt;

  FavoriteRoom({
    required this.id,
    required this.name,
    required this.url,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'addedAt': addedAt.toIso8601String(),
      };

  factory FavoriteRoom.fromJson(Map<String, dynamic> json) => FavoriteRoom(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
