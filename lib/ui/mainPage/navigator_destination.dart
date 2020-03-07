import 'package:flutter/material.dart';
import 'package:docup/constants/colors.dart';

/// Destination item data container for bottom navigation in main page.
///
/// Each item has:
/// - title: which may or may not be shown in bottom navigation
/// - icon: the icon shown in navigation
/// - color: the color of the icon (if present)
/// - image: the image which may be in navigation (for example in account)
/// - hasImage: whether it is icon based, or image based
class Destination {
  const Destination(
      this.title, this.icon, this.color, this.image, this.hasImage);

  final String title;
  final IconData icon;
  final MaterialColor color;
  final AssetImage image;
  final bool hasImage;
}

const List<Destination> navigator_destinations = <Destination>[
  Destination('Home', Icons.home, Colors.grey, AssetImage(''), false),
  Destination('Panel', Icons.view_quilt, Colors.grey, AssetImage(''), false),
  Destination('Settings', Icons.settings, Colors.grey, AssetImage(''), false),
  Destination('Account', Icons.account_box, Colors.grey,
      AssetImage('assets/lion.jpg'), true),
];
