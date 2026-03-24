class AppUser {
  final String id;
  final String name;

  AppUser({required this.id, required this.name});

  factory AppUser.fromJson(Map json) {
    return AppUser(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}