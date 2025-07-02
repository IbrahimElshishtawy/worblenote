import 'package:flutter/cupertino.dart';

class ClanderWidget extends StatelessWidget {
  final DateTime selectedDay;
  const ClanderWidget({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('التقويم')),
      child: Center(
        child: Text(
          'اليوم المحدد: ${selectedDay.year}-${selectedDay.month}-${selectedDay.day}',
        ),
      ),
    );
  }
}
