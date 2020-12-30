import 'package:flutter/material.dart';
import 'package:kpss_tercih/firebase/database.dart' as db;

class ChoiseButton extends StatelessWidget {
  final Function onClick;
  final String text;
  final Color color;

  const ChoiseButton({Key key, this.onClick, this.text,this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onClick,
      splashColor: Colors.amber,
      child: Text(text,
          style: TextStyle(
            color: color,
            fontSize: 13,
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: color),
      ),
    );
  }
}
