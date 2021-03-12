import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:flutter/material.dart';

/// Destination item data container for bottom navigation in main page.
///
/// Each item has:
/// - title: which may or may not be shown in bottom navigation
/// - icon: the icon shown in navigation
/// - color: the color of the icon (if present)
/// - image: the image which may be in navigation (for example in account)
/// - hasImage: whether it is icon based, or image based
class Destination {
  Destination(
      {this.title, this.icon, this.color, this.image, this.imgUrl, this.index});

  final String title;
  final IconData icon;
  final MaterialColor color;
  final int index;
  String image;
  Image imgUrl;

  get hasImage {
    return this.image != null;
  }
}

List<Destination> navigator_destinations = <Destination>[
  Destination(
      title: Strings.bottomNavigationHomeTitle,
      icon: Icons.home,
      color: Colors.grey, index: 0),
  Destination(
      title: Strings.bottomNavigationPanelTitle,
      icon: Icons.view_quilt,
      color: Colors.grey,
      image: Assets.panelIcon, index: 1),
  Destination(
      title: Strings.bottomNavigationServicesTitle,
      icon: Icons.settings,
      color: Colors.grey,
      image: Assets.servicesIcon, index: 2),
  Destination(
      title: Strings.bottomNavigationProfileTitle,
      icon: Icons.account_box,
      color: Colors.grey,
      image: Assets.profileIcon, index: 3),
];
