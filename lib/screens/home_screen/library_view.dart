import 'package:flutter/material.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({ Key key }) : super(key: key);

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("LibraryView"),
    );
  }
}