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
          if (constraints.maxWidth > 600) {
            return Container(
              color: bgColor,
              child: Center(
                child: SizedBox(
                  width: 820,
                  child: body,
                ),
              ),
            );
          }
          return body;
        },
      ),
    );
  }
}
