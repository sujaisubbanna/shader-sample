import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/shader_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FragmentShader? shader;
  ui.Image? image;
  double width = 0.001;
  Color color = Colors.blue;

  void loadMyShader() async {
    var program = await FragmentProgram.fromAsset('shaders/myshader.frag');
    shader = program.fragmentShader();
    setState(() {
      // trigger a repaint
    });
  }

  @override
  void initState() {
    super.initState();
    loadMyShader();
    loadImage();
  }

  Future<void> loadImage() async {
    image = await getUiImage('assets/images/sample.png', 600, 400);
    setState(() {
      // trigger a repaint
    });
  }

  Future<ui.Image> getUiImage(
      String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
      targetHeight: height,
      targetWidth: width,
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (shader != null && image != null)
            SizedBox(
              child: CustomPaint(
                size: const Size(600, 400),
                painter: ShaderPainter(
                  shader!,
                  color,
                  image!,
                  width,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Slider(
            min: 0.001,
            max: 0.01,
            value: width,
            onChanged: (value) {
              setState(() {
                width = value;
              });
            },
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    color = Colors.blue;
                  });
                },
                child: const Text('blue'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    color = Colors.red;
                  });
                },
                child: const Text('red'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    color = Colors.green;
                  });
                },
                child: const Text('green'),
              )
            ],
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
