import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {
  final List<String> banners = [
    'https://img.freepik.com/free-photo/fresh-vegetables_144627-15081.jpg',
    'https://img.freepik.com/free-photo/flat-lay-arrangement-vegetables_23-2148660479.jpg',
    'https://img.freepik.com/free-photo/top-view-vegetables-fruits-table_23-2148685394.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: banners.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
            );
          },
        );
      }).toList(),
    );
  }
}
