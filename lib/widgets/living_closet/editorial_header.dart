import 'package:flutter/material.dart';

class LivingClosetEditorialHeader extends StatelessWidget {
  final int activeSectionIndex;
  final ValueChanged<int> onSectionSelected;

  const LivingClosetEditorialHeader({
    super.key,
    required this.activeSectionIndex,
    required this.onSectionSelected,
  });

  static const List<Map<String, dynamic>> sections = [
    {
      'title': 'Collection',
      'subtitle': 'Curated Wardrobe',
      'icon': Icons.grid_view_rounded,
    },
    {
      'title': 'Style Studio',
      'subtitle': 'Outfit Desk',
      'icon': Icons.palette_outlined,
    },
    {
      'title': 'Outfit DNA',
      'subtitle': 'Garment Harmony',
      'icon': Icons.auto_awesome_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Block taking full width to ensure text is never truncated or cut in half
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EVOQE',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5,
                color: Color(0xFF888077),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'My Digital Closet',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Color(0xFF201D19),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'The Living Closet · Your wardrobe, reimagined.',
              style: TextStyle(
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: Color(0xFF6E6760),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Magazine-Style Segmented Navigation Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(sections.length, (index) {
              final section = sections[index];
              final isSelected = activeSectionIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => onSectionSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFEFECE4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3E3129) : const Color(0xFFCDC6BA),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF3E3129).withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          section['icon'] as IconData,
                          size: 15,
                          color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF3E3129),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          section['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFFF5F3EC) : const Color(0xFF201D19),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
