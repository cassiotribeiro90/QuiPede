import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ResponsivePageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const ResponsivePageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: bgColor,
      bottomNavigationBar: bottomNavigationBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 🔥 DETECTA SE É WEB E AJUSTA A LARGURA
          const isWeb = kIsWeb;
          final bool isLargeScreen = constraints.maxWidth > 600;

          if (isLargeScreen) {
            // 🔥 WEB: 1200px | TABLET/DESKTOP: 820px
            const maxWidth = isWeb ? 1200.0 : 820.0;

            return Container(
              color: bgColor,
              child: Center(
                child: SizedBox(
                  width: maxWidth,
                  child: body,
                ),
              ),
            );
          }

          // Mobile: largura total
          return body;
        },
      ),
    );
  }
}