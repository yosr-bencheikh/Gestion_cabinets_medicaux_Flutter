import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Category extends StatelessWidget {
   final iconImagePath;
   final String categoryName;
  Category({
    required this.iconImagePath,
    required this.categoryName,
});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:46.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Image.network(iconImagePath,height: 70,),
            Text((categoryName)),

          ],
        ),

      ),
    );
  }
}
