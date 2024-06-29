import 'package:flutter/material.dart';

import '../export/export.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final bool isLightTheme;
  final GlobalKey itemKey;

  const CategoryItem({super.key, 
    required this.category,
    required this.isSelected,
    required this.isLightTheme,
    required this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: itemKey,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          category.title,
          style: TextStyle(
            fontSize: 16,
            color: isSelected
                ? (isLightTheme ? Colors.white : Colors.black.withOpacity(.8))
                : Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
