import 'dart:ui';

import 'package:flutter/material.dart';

class BlurClipRect extends StatelessWidget {
  const BlurClipRect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
