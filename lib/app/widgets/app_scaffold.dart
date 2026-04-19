import 'package:flutter/material.dart';
import '../core/layout/app_layout.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool? resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.drawer,
    this.scaffoldKey,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Opção 1: SizedBox com largura fixa e altura fluida
          if (constraints.maxWidth > AppLayout.breakpoint) {
            return Center(
              child: SizedBox(
                width: AppLayout.maxContentWidth,
                child: body,
              ),
            );
          }
          return body;
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (bottomNavigationBar == null) return const SizedBox.shrink();
          
          if (constraints.maxWidth > AppLayout.breakpoint) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
                child: bottomNavigationBar!,
              ),
            );
          }
          return bottomNavigationBar!;
        },
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
