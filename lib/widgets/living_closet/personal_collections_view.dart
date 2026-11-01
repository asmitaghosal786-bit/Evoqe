import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_state.dart';
import '../../models/personal_collection.dart';
import '../../models/garment_item.dart';
import '../../screens/welcome_screen.dart';

class PersonalCollectionsScreen extends StatefulWidget {
  const PersonalCollectionsScreen({super.key});

  @override
  State<PersonalCollectionsScreen> createState() => _PersonalCollectionsScreenState();
}

class _PersonalCollectionsScreenState extends State<PersonalCollectionsScreen> {
  Future<void> _showCreateCollectionDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5F3EC),
        title: const Text('Create Personal Collection', style: TextStyle(fontFamily: 'serif', color: Color(0xFF201D19))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Collection Name (e.g., Black & Ivory)',
                filled: true,
                fillColor: Color(0xFFEFECE4),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                filled: true,
                fillColor: Color(0xFFEFECE4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888077))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E3129),
              foregroundColor: const Color(0xFFF5F3EC),
            ),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newCol = PersonalCollection(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                );
                context.read<SessionState>().addPersonalCollection(newCol);
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal collection created.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final collections = session.personalCollections;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF201D19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const EvoqeHeaderLogo(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Personal Collections',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3E3129)),
                    onPressed: () => _showCreateCollectionDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Organize your actual wardrobe garments into themed personal edits.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6E6760)),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: collections.isEmpty
                    ? const Center(
                        child: Text('No personal collections yet.', style: TextStyle(color: Color(0xFF888077))),
                      )
                    : ListView.builder(
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          final garmentsInCol = session.garments.where((g) => collection.garmentIds.contains(g.id)).toList();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFECE4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCDC6BA)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      collection.name,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF201D19),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFA33A3A)),
                                      onPressed: () {
                                        session.deletePersonalCollection(collection.id);
                                      },
                                    ),
                                  ],
                                ),
                                if (collection.description.isNotEmpty) ...[
                                  Text(
                                    collection.description,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6E6760)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text(
                                  '${garmentsInCol.length} garments',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF888077)),
                                ),
                                const SizedBox(height: 10),

                                // Garments in Collection cutouts
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ...garmentsInCol.map((g) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          width: 60,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F3EC),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFCDC6BA)),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: _buildGarmentImage(g),
                                                ),
                                              ),
                                              Positioned(
                                                top: 2,
                                                right: 2,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    session.removeGarmentFromCollection(collection.id, g.id);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(1),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFA33A3A),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.close, size: 10, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      GestureDetector(
                                        onTap: () => _showAddGarmentToCollectionSheet(context, collection, session),
                                        child: Container(
                                          width: 60,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2DDD3),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFCDC6BA)),
                                          ),
                                          child: const Icon(Icons.add, color: Color(0xFF3E3129)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGarmentToCollectionSheet(BuildContext context, PersonalCollection collection, SessionState session) {
    final availableGarments = session.garments.where((g) => !collection.garmentIds.contains(g.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F3EC),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Garments to "${collection.name}"',
                style: const TextStyle(fontFamily: 'serif', fontSize: 18, color: Color(0xFF201D19)),
              ),
              const SizedBox(height: 12),
              if (availableGarments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('All closet garments are already in this collection.', style: TextStyle(color: Color(0xFF888077))),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableGarments.length,
                    itemBuilder: (context, index) {
                      final garment = availableGarments[index];
                      return ListTile(
                        leading: SizedBox(width: 40, height: 40, child: _buildGarmentImage(garment)),
                        title: Text(garment.name),
                        subtitle: Text('${garment.category} · ${garment.primaryColor}'),
                        trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF3E3129)),
                        onTap: () {
                          session.addGarmentToCollection(collection.id, garment.id);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGarmentImage(GarmentItem garment) {
    final path = garment.cutoutPath.isNotEmpty ? garment.cutoutPath : garment.imagePath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 20));
    } else if (path.isNotEmpty && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.contain, errorBuilder: (context, error, trace) => const Icon(Icons.checkroom, size: 20));
    } else {
      return Container(
        color: const Color(0xFFE2DDD3),
        child: const Icon(Icons.checkroom, size: 20, color: Color(0xFF8C8278)),
      );
    }
  }
}
