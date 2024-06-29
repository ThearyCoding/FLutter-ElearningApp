import 'package:e_leaningapp/controller/banner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

class BannerWidget extends StatelessWidget {
  final BannerController bannerController = Get.put(BannerController());

  BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (bannerController.isLoading.value) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 90.0,
            color: Colors.white,
          ),
        );
      } else if (bannerController.banners.isEmpty) {
        return const Center(
          child: Text("No Banners Found!"),
        );
      } else {
        return LayoutBuilder(
          builder: (context, constraints) {
            double height;
            if (constraints.maxWidth < 360) {
              // Small mobile devices
              height = 90.0;
            } else if (constraints.maxWidth < 480) {
              // Medium mobile devices
              height = 100.0;
            } else if (constraints.maxWidth < 600) {
              // Large mobile devices
              height = 110.0;
            } else {
              // Tablets
              height = 140.0;
            }

            return CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                height: height,
                autoPlay: true,
                enlargeCenterPage: true,
                padEnds: false,
              ),
              items: bannerController.banners.map((banner) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: constraints.maxWidth, // Use the full width of the device
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          banner.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: constraints.maxWidth,
                                  height: height,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: constraints.maxWidth,
                              height: height,
                              color: Colors.grey,
                              child: const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      }
    });
  }
}
