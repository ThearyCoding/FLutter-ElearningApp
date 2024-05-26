import 'package:e_leaningapp/widgets/shimer_image_widget.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const CategoryCard({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ShimmerImage(
              imageUrl: imageUrl,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}