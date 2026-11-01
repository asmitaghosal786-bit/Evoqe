class PersonalCollection {
  final String id;
  String name;
  String description;
  List<String> garmentIds;
  DateTime createdAt;

  PersonalCollection({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? garmentIds,
    DateTime? createdAt,
  })  : garmentIds = garmentIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'garmentIds': garmentIds,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory PersonalCollection.fromJson(Map<String, dynamic> json) => PersonalCollection(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        garmentIds: (json['garmentIds'] as List?)?.map((e) => e as String).toList() ?? [],
        createdAt: json['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
            : DateTime.now(),
      );
}
