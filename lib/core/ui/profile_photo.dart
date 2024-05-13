import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
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
                  return Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  );
                },
                placeholder: (context, url) {
                  return Image.asset(
                    Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                  );
                },
                errorWidget: (context, url, error) {
                  return Image.asset(
                    Assets.imagesUserProfile,
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
    );
  }
}
