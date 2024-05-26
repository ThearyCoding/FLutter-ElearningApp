import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const ShimmerImage({super.key, 
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height,
            width: width,
            color: Colors.white,
          ),
        ),
        Image.network(
          imageUrl,
          height: height,
          width: width,
          fit: fit,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: height,
                  width: width,
                  color: Colors.white,
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            );
          },
        ),
      ],
    );
  }
}