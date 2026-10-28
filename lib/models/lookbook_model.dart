import 'package:flutter/material.dart';

class LookbookReference {
  final String id;
  final String imagePath;
  String label;
  String category;

  LookbookReference({
    required this.id,
    required this.imagePath,
    required this.label,
    this.category = 'General',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'label': label,
        'category': category,
      };

  factory LookbookReference.fromJson(Map<String, dynamic> json) => LookbookReference(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        label: json['label'] as String,
        category: json['category'] as String? ?? 'General',
      );
}

class LookbookAnalysisResult {
  final String headline;
  final String summary;
  final List<Color> paletteColors;
  final String paletteName;
  final List<String> styleTags;

  const LookbookAnalysisResult({
    required this.headline,
    required this.summary,
    required this.paletteColors,
    required this.paletteName,
    required this.styleTags,
  });
}

class LookbookModel {
  final String id;
  String title;
  String aestheticDescription;
  List<LookbookReference> references;
  List<String> customCategories;
  DateTime createdAt;

  LookbookModel({
    required this.id,
    required this.title,
    required this.aestheticDescription,
    required this.references,
    required this.customCategories,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'aestheticDescription': aestheticDescription,
        'references': references.map((r) => r.toJson()).toList(),
        'customCategories': customCategories,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory LookbookModel.fromJson(Map<String, dynamic> json) => LookbookModel(
        id: json['id'] as String,
        title: json['title'] as String,
        aestheticDescription: json['aestheticDescription'] as String,
        references: (json['references'] as List?)
                ?.map((r) => LookbookReference.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        customCategories: (json['customCategories'] as List?)
                ?.map((c) => c as String)
                .toList() ??
            [],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}

class LookbookAnalyzer {
  static LookbookAnalysisResult analyze(LookbookModel lookbook) {
    final desc = lookbook.aestheticDescription.toLowerCase();
    final categories = lookbook.customCategories.map((c) => c.toLowerCase()).join(' ');
    final combinedText = '$desc $categories';

    String headline = 'Quiet luxury. A romantic edge.';
    if (combinedText.contains('vintage') || combinedText.contains('retro') || combinedText.contains('classic')) {
      headline = 'Timeless vintage character with bespoke tailoring.';
    } else if (combinedText.contains('minimal') || combinedText.contains('clean') || combinedText.contains('simple')) {
      headline = 'Purity of line. Effortless minimalism.';
    } else if (combinedText.contains('street') || combinedText.contains('urban') || combinedText.contains('bold')) {
      headline = 'Modern urban energy with structured edges.';
    } else if (combinedText.contains('boho') || combinedText.contains('bohemian') || combinedText.contains('earthy')) {
      headline = 'Earthy textures and relaxed bohemian warmth.';
    } else if (combinedText.contains('romantic') || combinedText.contains('soft') || combinedText.contains('dreamy')) {
      headline = 'Soft romanticism and fluid draping.';
    } else if (lookbook.aestheticDescription.trim().isNotEmpty) {
      headline = lookbook.aestheticDescription.length > 40
          ? '${lookbook.aestheticDescription.substring(0, 40)}...'
          : lookbook.aestheticDescription;
    }

    String summary = 'Your references pair precise tailoring with softer textures. Warm neutrals and delicate gold give the edit an understated, personal rhythm.';
    if (combinedText.contains('vintage')) {
      summary = 'Rich heritage tones and nostalgic silhouettes create an evocative narrative anchored in classic tailoring.';
    } else if (combinedText.contains('minimal')) {
      summary = 'Streamlined silhouettes, monochrome foundations, and refined fabrics define this understated look.';
    } else if (combinedText.contains('street')) {
      summary = 'Bold contrasts and relaxed volumes deliver contemporary streetwear sophistication.';
    }

    List<Color> palette = const [
      Color(0xFFFAF8F5),
      Color(0xFFE2DDD3),
      Color(0xFF3E3129),
      Color(0xFF555E4E),
    ];
    String paletteName = 'Ivory · taupe · espresso · muted olive';

    if (combinedText.contains('blue') || combinedText.contains('denim') || combinedText.contains('cool')) {
      palette = const [Color(0xFFF0F4F8), Color(0xFFD9E2EC), Color(0xFF243B53), Color(0xFF486581)];
      paletteName = 'Ice white · slate · navy · steel blue';
    } else if (combinedText.contains('black') || combinedText.contains('dark') || combinedText.contains('noir')) {
      palette = const [Color(0xFF111111), Color(0xFF333333), Color(0xFF666666), Color(0xFFB0B0B0)];
      paletteName = 'Obsidian · charcoal · ash · silver';
    } else if (combinedText.contains('warm') || combinedText.contains('gold') || combinedText.contains('amber') || combinedText.contains('rust')) {
      palette = const [Color(0xFFFDF6EC), Color(0xFFE5C158), Color(0xFF8C5830), Color(0xFF4A2E18)];
      paletteName = 'Cream · warm gold · terracotta · espresso';
    }

    Set<String> tags = {'Quiet luxury'};
    if (combinedText.contains('vintage') || combinedText.contains('retro')) tags.add('Vintage revival');
    if (combinedText.contains('minimal') || combinedText.contains('clean')) tags.add('Modern minimal');
    if (combinedText.contains('romantic') || combinedText.contains('soft')) tags.add('Soft romantic');
    if (combinedText.contains('street') || combinedText.contains('urban')) tags.add('Urban streetwear');
    if (combinedText.contains('tailor') || combinedText.contains('formal')) tags.add('Bespoke tailoring');
    if (combinedText.contains('casual') || combinedText.contains('relax')) tags.add('Relaxed luxury');
    if (tags.length < 3) {
      tags.add('Curated edit');
      tags.add('Statement texture');
    }

    return LookbookAnalysisResult(
      headline: headline,
      summary: summary,
      paletteColors: palette,
      paletteName: paletteName,
      styleTags: tags.toList(),
    );
  }
}
