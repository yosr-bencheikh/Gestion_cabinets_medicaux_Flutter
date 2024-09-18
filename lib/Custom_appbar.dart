import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key, this.appTitle, this.route, this.icon, this.actions}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  final String? appTitle;
  final String? route;
  final Icon? icon;
  final List<Widget>? actions;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {


  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.appTitle ?? '', // Access appTitle from widget instance
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      leading: widget.icon != null
          ? Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: widget.icon,
      )
          : null,
      actions: widget.actions ?? [],
    );
  }
}
