class Cast {
  final int id;
  final String name;
  final String originalName;
  final String character;
  String? profilePath;

  Cast(
      {required this.id,
      required this.originalName,
      required this.name,
      required this.character,
      required this.profilePath});

  factory Cast.fromJson(Map<String, dynamic> json) {
    print(json);
    return Cast(
        id: json['id'],
        name: json['name'],
        profilePath: json['profile_path'],
        character: json['character'],
        originalName: json['original_name']);
  }
}
