import 'package:flutter/cupertino.dart';
import 'clander_widget.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('نشاطك')),
      child: Center(
        child: CupertinoButton.filled(
          child: const Text('عرض التقويم'),
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ClanderWidget(selectedDay: DateTime.now()),
            ),
          ),
        ),
      ),
    );
  }
}
