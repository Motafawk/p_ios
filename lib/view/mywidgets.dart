import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import '../funs.dart' as f;

class MyImageGalleryCache extends StatelessWidget {
  final String imageName;
  final BoxFit boxFit;
  const MyImageGalleryCache({Key? key, required this.imageName, this.boxFit = BoxFit.fill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rand = Random().nextInt(1000000).toString();
    // print("${v.storageLink}${imageName}");
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: Hero(
            tag: "${imageName}_${rand}",
            child: f.imageUrl("${imageName}", boxFit: boxFit),
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.black,
                // primary: Colors.black.withOpacity(0.1), //
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))
              ),
              child: Text(""),
              onPressed: () async {
                SwipeImageGallery(
                  context: context,
                  // children: [Image(image: AssetImage('assets/images/logo.png')),],
                  children: [
                    f.imageUrl("${imageName}", boxFit: BoxFit.contain),
                  ],
                  initialIndex: 0,
                  heroProperties: [ImageGalleryHeroProperties(tag: "${imageName}_${rand}"),],
                  hideStatusBar: false,
                ).show();
              },
            )
        ),
      ],
    );
  }
}

class MyImageGalleryNetwork extends StatelessWidget {
  final String imageUrl;
  final BoxFit boxFit;
  const MyImageGalleryNetwork({Key? key, required this.imageUrl, this.boxFit = BoxFit.fill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rand = Random().nextInt(1000000).toString();
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: Hero(
            tag: "${imageUrl}_${rand}",
            child: Image.network(
              "${imageUrl}",
              fit: boxFit,
              errorBuilder: (context, obj, st){
                return Icon(Icons.error, color: Colors.red,);
              },
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress){
                if (loadingProgress == null) return child;
                return Container(
                  padding: EdgeInsets.all(4),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                  onPrimary: Colors.black
              ),
              child: Text(""),
              onPressed: () async {
                SwipeImageGallery(
                  context: context,
                  children: [Image.network(
                    "${imageUrl}",
                    fit: BoxFit.contain,
                    errorBuilder: (context, obj, st){
                      return Icon(Icons.error, color: Colors.red,);
                    },
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress){
                      if (loadingProgress == null) return child;
                      return Container(
                        padding: EdgeInsets.all(4),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),],
                  initialIndex: 0,
                  heroProperties: [ImageGalleryHeroProperties(tag: "${imageUrl}_${rand}"),],
                ).show();
              },
            )
        ),
      ],
    );
  }
}

