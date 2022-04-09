import 'package:flutter/material.dart';

class TopChartsView extends StatefulWidget {
  const TopChartsView({ Key key }) : super(key: key);

  @override
  State<TopChartsView> createState() => _TopChartsViewState();
}

class _TopChartsViewState extends State<TopChartsView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("TopChartsView"),
    );
  }
}