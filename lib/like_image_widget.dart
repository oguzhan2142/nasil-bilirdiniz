import 'package:flutter/material.dart';
import 'package:kpss_tercih/Resources.dart' as Res;

class LikeImage extends StatefulWidget {
  final double size;
  String currentImagePath;
  

  LikeImage({Key key, this.size}) : super(key: key);

  void updateImage(bool isLiked) {
    currentImagePath = !isLiked ? Res.liked : Res.unliked;
  }

  @override
  _LikeImageState createState() => _LikeImageState();
}

class _LikeImageState extends State<LikeImage> {
  @override
  void initState() {
    super.initState();
    widget.currentImagePath = Res.unliked;
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.currentImagePath,
      width: widget.size,
      color: Colors.amber,
      
    );
  }
}
