import 'package:flutter/cupertino.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('لعبة Wordle')),
      child: Center(child: Text('صفحة اللعبة')),
    );
  }
}
