import 'package:flutter/material.dart';

class MonsterModel {
  String bodyShape;
  String eyeType;
  String mouthType;
  String hornType;
  Color bodyColor;
  Color hornColor;

  MonsterModel({
    this.bodyShape = 'fluffy',
    this.eyeType = 'single',
    this.hornType = 'curved',
    this.mouthType = 'dull_happy',
    this.bodyColor = const Color(0xFF66B7AC),
    this.hornColor = const Color(0xFFE6D3B3),
  });
}
