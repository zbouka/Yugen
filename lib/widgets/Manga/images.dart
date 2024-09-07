import 'package:flutter/material.dart';
import 'package:photo_view_v3/photo_view_gallery.dart';

import 'package:yugen/widgets/Recycled/get_color.dart';

/// Shows the manga images
class MangaImages extends StatefulWidget {
  final List<dynamic> mangaImages;
  const MangaImages({super.key, required this.mangaImages});

  @override
  State<MangaImages> createState() => _MangaImagesState();
}

class _MangaImagesState extends State<MangaImages> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getCurrentColor(false),
      bottomSheet: IconButton(
          onPressed: () {
            setState(() {
              pressed = !pressed;
            });
          },
          icon: const Icon(Icons.repeat)),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        allowImplicitScrolling: true,
        reverse: pressed,
        backgroundDecoration: const BoxDecoration(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: Image.network(
              widget.mangaImages[index],
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                    child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ));
              },
            ).image,
          );
        },
        itemCount: widget.mangaImages.length,
      ),
    );
  }
}
