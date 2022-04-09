import 'package:flutter/material.dart';

class NewFeedView extends StatefulWidget {
  const NewFeedView({ Key key }) : super(key: key);

  @override
  State<NewFeedView> createState() => _NewFeedViewState();
}

class _NewFeedViewState extends State<NewFeedView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("NewFeedView"),
    );
  }
}