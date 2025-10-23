// lib/widgets/category_chips.dart
import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<String?> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.categories.map((category) {
        return ChoiceChip(
          label: Text(category),
          selected: selectedCategory == category,
          labelStyle: const TextStyle(
            fontSize: 12, // Daha küçük font
            fontWeight: FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(width: 0.5), // İnce kenarlık
          ),
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
          onSelected: (selected) {
            setState(() {
              selectedCategory = selected ? category : null;
            });
            widget.onSelected(selected ? category : null);
          },
        );
      }).toList(),
    );
  }
}
