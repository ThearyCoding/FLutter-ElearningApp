import 'package:e_leaningapp/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CourseShimerWidget extends StatelessWidget {
  const CourseShimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        childAspectRatio: getChildAspectRatio(context),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          direction: ShimmerDirection.ttb,
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(8),
          ),
        );
      },
    );
  }
}
