import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/monster_model.dart';

class MonsterAvatar extends StatelessWidget {
  final MonsterModel monster;

  const MonsterAvatar({super.key, required this.monster});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (monster.hornType != 'none')
            Transform.translate(
              offset: const Offset(0, -70),
              child: SvgPicture.asset(
                'assets/images/monster_maker/horns/${monster.hornType}.svg',
                color: monster.hornColor,
                height: 100,
                width: 100,
              ),
            ),

          SvgPicture.asset(
            'assets/images/monster_maker/bodies/${monster.bodyShape}.svg',
            color: monster.bodyColor,
            height: 200,
            width: 200,
          ),

          Transform.translate(
            offset: const Offset(0, -10),
            child: SvgPicture.asset(
              'assets/images/monster_maker/eyes/${monster.eyeType}.svg',
              width: _getEyeWidth(monster.eyeType),
            ),
          ),

          Transform.translate(
            offset: const Offset(0, 40),
            child: SvgPicture.asset(
              'assets/images/monster_maker/mouths/${monster.mouthType}.svg',
              width: 100,
            ),
          ),
        ],
      ),
    );
  }

  double _getEyeWidth(String eyeType) {
    switch (eyeType) {
      case 'single':
        return 70;
      default:
        return 100;
    }
  }
}
