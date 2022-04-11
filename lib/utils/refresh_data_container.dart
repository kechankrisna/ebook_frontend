import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RefreshDataContainer extends StatelessWidget {
  final Function() onPressed;
  final String error;
  const RefreshDataContainer({Key key, this.onPressed, this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(MdiIcons.databaseCheckOutline, size: 46),
          SizedBox(height: 10),
          Text("no data"),
          SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(Icons.refresh),
            label: Container(
              padding: EdgeInsets.all(5),
              child: Text("try again"),
            ),
          )
        ],
      ),
    );
  }
}
