import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final Color color;
  final ui.Image image;
  final double width;

  ShaderPainter(
    FragmentShader fragmentShader,
    this.color,
    this.image,
    this.width,
  ) : shader = fragmentShader;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    shader.setFloat(2, color.red / 255);
    shader.setFloat(3, color.green / 255);
    shader.setFloat(4, color.blue / 255);
    shader.setFloat(5, color.alpha / 255);

    shader.setFloat(6, width);

    shader.setImageSampler(0, image);

    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(ShaderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.image != image ||
      oldDelegate.width != width;
}
