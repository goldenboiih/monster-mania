import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'models/monster_model.dart';
import 'widgets/monster_avatar.dart';
import 'widgets/color_selector.dart';
import 'conf/monster_colors.dart';

class AvatarMakerScreen extends StatefulWidget {
  const AvatarMakerScreen({super.key});

  @override
  State<AvatarMakerScreen> createState() => _AvatarMakerScreenState();
}

class _AvatarMakerScreenState extends State<AvatarMakerScreen> {
  final monster = MonsterModel();
  final GlobalKey avatarKey = GlobalKey();
  final Map<String, List<String>> options = {
    'body': ['fluffy', 'spiky', 'wooly'],
    'eyes': ['single', 'two', 'three'],
    'horns': ['curved', 'straight', 'thick', 'out', 'none'],
    'mouth': ['dull_happy', 'sharp', 'fangs'],
  };

  final Map<String, int> indexes = {
    'body': 0,
    'eyes': 0,
    'horns': 0,
    'mouth': 0,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _applySelection();
  }

  void _applySelection() {
    monster.bodyShape = options['body']![indexes['body']!];
    monster.eyeType = options['eyes']![indexes['eyes']!];
    monster.hornType = options['horns']![indexes['horns']!];
    monster.mouthType = options['mouth']![indexes['mouth']!];
  }

  void updatePart(String part, int direction) {
    setState(() {
      final list = options[part]!;
      indexes[part] = (indexes[part]! + direction) % list.length;
      if (indexes[part]! < 0) indexes[part] = list.length - 1;
      _applySelection();
    });
  }

  Future<void> _saveAvatar() async {
    try {
      final boundary = avatarKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Now you can:
      // - Save to file
      // - Show in dialog
      // - Upload
      // For testing, show it in a dialog:

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: SizedBox(
            width: 200,
            height: 200,
            child: Image.memory(pngBytes, fit: BoxFit.contain),
          ),
        ),
      );

      // Optionally save to file using path_provider + dart:io
    } catch (e) {
      debugPrint('Error saving avatar: $e');
    }
  }


  Widget buildSelector(String part) {
    return SizedBox(
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, size: 30),
            onPressed: () => updatePart(part, -1),
          ),
          Text(part),
          IconButton(
            icon: const Icon(Icons.arrow_right, size: 30),
            onPressed: () => updatePart(part, 1),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monster Maker')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              RepaintBoundary(
                key: avatarKey,
                child: Container(color: Colors.blue, child: MonsterAvatar(monster: monster)),
              ),

              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  buildSelector('body'),
                  buildSelector('eyes'),
                  buildSelector('horns'),
                  buildSelector('mouth'),
                ],
              ),

              ColorSelector(
                label: 'Body Color',
                currentColor: monster.bodyColor,
                onColorChanged:
                    (color) => setState(() => monster.bodyColor = color),
                colors: MonsterColors.bodyColors
              ),
              const SizedBox(height: 10),
              ColorSelector(
                label: 'Horn Color',
                currentColor: monster.hornColor,
                onColorChanged:
                    (color) => setState(() => monster.hornColor = color),
                colors: MonsterColors.hornColors
              ),
              ElevatedButton(
                onPressed: _saveAvatar,
                child: const Text('Save Avatar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
