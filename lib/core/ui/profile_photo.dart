import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    super.key,
    this.url,
    this.dimension = 140,
    this.isGroup = false,
  });

  final String? url;
  final bool isGroup;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: const ShapeDecoration(
        shape: CircleBorder(),
        shadows: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipOval(
        child: (url == null)
            ? Image.asset(
                Assets.imagesUserProfile,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl: url!,
                imageBuilder: (context, imageProvider) {
                  return GestureDetector(
                    onTap: () => showImageViewer(
                      context,
                      imageProvider,
                      swipeDismissible: true,
                      useSafeArea: true,
                      doubleTapZoomable: true,
                      immersive: false,
                    ),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  );
                },
                placeholder: (context, url) {
                  return Image.asset(
                    isGroup ? Assets.iconsTeam : Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                  );
                },
                errorWidget: (context, url, error) {
                  return Image.asset(
                    isGroup ? Assets.iconsTeam : Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
    );
  }
}
