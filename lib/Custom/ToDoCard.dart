import 'package:flutter/material.dart';

class Todocard extends StatelessWidget {
  const Todocard(
      {super.key,
      required this.title,
      required this.iconData,
      required this.iconColor,
      this.time,
      required this.check,
      required this.iconBgColor,
      this.onChange,
      this.index});

  final String title;
  final IconData iconData;
  final Color iconColor;
  final String? time;
  final bool check;
  final Color iconBgColor;
  final Function? onChange;
  final int? index;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
         
          Expanded(
            child: SizedBox(
              height: 75,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: const Color(0xff2a2e3d),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 33,
                      width: 36,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(iconData, color: iconColor),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      time ?? "",
                       style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}