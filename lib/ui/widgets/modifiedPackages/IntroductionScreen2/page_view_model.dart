import 'package:flutter/material.dart';

import 'page_decoration.dart';

class PageViewModel2 {
  /// Title of page
  final String title;

  /// Title of page
  final Widget titleWidget;

  /// Text of page (description)
  final String body;

  /// Widget content of page (description)
  final Widget bodyWidget;

  /// Image of page
  /// Tips: Wrap your image with an alignment widget like Align or Center
  final Widget image;

  /// Footer widget, you can add a button for example
  final Widget footer;

  /// Page decoration
  /// Contain all page customizations, like page color, text styles
  final PageDecoration2 decoration;
  final Widget wholePageChild;

  PageViewModel2({
    this.title,
    this.titleWidget,
    this.body,
    this.bodyWidget,
    this.image,
    this.footer,
    this.wholePageChild,
    this.decoration = const PageDecoration2(),
  })  : assert(
          title != null || titleWidget != null || wholePageChild != null,
          "You must provide either title (String) or titleWidget (Widget).",
        ),
        assert(
          (title == null) != (titleWidget == null) || wholePageChild != null,
          "You can not provide both title and titleWidget.",
        ),
        assert(
          body != null || bodyWidget != null || wholePageChild != null,
          "You must provide either body (String) or bodyWidget (Widget).",
        ),
        assert(
          (body == null) != (bodyWidget == null) || wholePageChild != null,
          "You can not provide both body and bodyWidget.",
        );
}
