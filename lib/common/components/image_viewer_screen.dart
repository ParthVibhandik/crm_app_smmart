import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';

class ImageViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const ImageViewerScreen({super.key, required this.url, this.title = 'Image Preview'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
          backgroundDecoration: BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
