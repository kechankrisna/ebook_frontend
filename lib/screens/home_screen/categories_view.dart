import 'package:flutter/material.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({ Key key }) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("CategoriesView"),
    );
  }
}