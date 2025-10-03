import 'package:flutter/material.dart';

class GameCardData {
  final String title;
  final Widget Function() builder;
  GameCardData(this.title, this.builder);
}
