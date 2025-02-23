import 'package:chatbox/components/sidebar.dart';
import 'package:chatbox/screens/homepage.dart';
import 'package:flutter/material.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: width * 0.13, height: height, child: Sidebar()),
          Expanded(
            child: SizedBox(
              width: width * 0.87,
              height: height,
              child: Homepage(),
            ),
          ),
        ],
      ),
    );
  }
}
