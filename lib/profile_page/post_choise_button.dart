import 'package:flutter/material.dart';

class ChoiseButton extends StatelessWidget {
  final Function onClick;
  final String text;
  final Color borderColor;
  final Color textColor;

  const ChoiseButton(
      {Key key, this.textColor, this.onClick, this.text, this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onClick,
      splashColor: Colors.amber,
      child: Text(text,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
          )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor),
      ),
    );
  }
}
