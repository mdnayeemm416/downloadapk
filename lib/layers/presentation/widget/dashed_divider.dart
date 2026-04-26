import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 100,
        itemBuilder: (context, index) => Container(width: 8, color: Colors.grey),
        separatorBuilder: (context, index) => SizedBox(width: 4),
      ),
    );
  }
}
