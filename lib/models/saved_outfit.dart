class CanvasPosition {
  final String garmentId;
  double dx;
  double dy;
  double scale;
  double rotation;

  CanvasPosition({
    required this.garmentId,
    this.dx = 0.5,
    this.dy = 0.5,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'garmentId': garmentId,
        'dx': dx,
        'dy': dy,
        'scale': scale,
        'rotation': rotation,
      };

  factory CanvasPosition.fromJson(Map<String, dynamic> json) => CanvasPosition(
        garmentId: json['garmentId'] as String,
        dx: (json['dx'] as num?)?.toDouble() ?? 0.5,
        dy: (json['dy'] as num?)?.toDouble() ?? 0.5,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      );
}

class SavedOutfit {
  final String id;
  String name;
  String occasion;
  List<String> tags;
  List<CanvasPosition> positions;
  DateTime createdAt;

  SavedOutfit({
    required this.id,
    required this.name,
    this.occasion = 'Everyday',
    List<String>? tags,
    List<CanvasPosition>? positions,
    DateTime? createdAt,
  })  : tags = tags ?? [],
        positions = positions ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'occasion': occasion,
        'tags': tags,
        'positions': positions.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory SavedOutfit.fromJson(Map<String, dynamic> json) => SavedOutfit(
        id: json['id'] as String,
        name: json['name'] as String,
        occasion: json['occasion'] as String? ?? 'Everyday',
        tags: (json['tags'] as List?)?.map((t) => t as String).toList() ?? [],
        positions: (json['positions'] as List?)
                ?.map((p) => CanvasPosition.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
            : DateTime.now(),
      );
}
