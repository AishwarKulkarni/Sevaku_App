import 'package:flutter/material.dart';

class MyAppLayout extends StatefulWidget {
  final PreferredSizeWidget? appbarWidget;
  final Widget? drawerWidget;
  final Widget bodyWidget;
  final Widget? bottomNavigationWidget;
  final Widget? bottomSheetWidget;
  final Color? backGroundColor;
  const MyAppLayout({
    super.key,
    this.appbarWidget,
    this.drawerWidget,
    required this.bodyWidget,
    this.bottomNavigationWidget,
    this.bottomSheetWidget,
    this.backGroundColor,
  });

  @override
  State<MyAppLayout> createState() => _MyAppLayoutState();
}

class _MyAppLayoutState extends State<MyAppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbarWidget,
      drawer: widget.drawerWidget,
      body: widget.bodyWidget,
      bottomNavigationBar: widget.bottomNavigationWidget,
      bottomSheet: widget.bottomSheetWidget,
      backgroundColor: widget.backGroundColor,
    );
  }
}
