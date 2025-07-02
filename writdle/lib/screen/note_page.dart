import 'package:flutter/cupertino.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('ملاحظات')),
      child: Center(child: Text('صفحة الملاحظات')),
    );
  }
}
