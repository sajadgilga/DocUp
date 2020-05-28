import 'package:docup/constants/assets.dart';
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
  Destination(this.title, this.icon, this.color, this.image, this.isProfile,
      {this.img, this.hasImage = false});

  final String title;
  final IconData icon;
  final MaterialColor color;
  String image;
  Image img;
  bool isProfile;
  bool hasImage;
}

List<Destination> navigator_destinations = <Destination>[
  Destination('Home', Icons.home, Colors.grey, '', false),
  Destination('Panel', Icons.assignment, Colors.grey, Assets.clinicPanel, false,
      hasImage: true),
  Destination('Panel', Icons.view_quilt, Colors.grey, '', false),
  Destination('Settings', Icons.settings, Colors.grey, '', false),
  Destination(
      'Account', Icons.account_box, Colors.grey, 'assets/avatar.png', true),
];
