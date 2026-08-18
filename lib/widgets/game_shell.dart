import 'package:flutter/material.dart';

/// Lets nested tab scaffolds open the game shell drawer.
class GameShell extends InheritedWidget {
  const GameShell({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  static GameShell? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameShell>();
  }

  static void open(BuildContext context) {
    maybeOf(context)?.openDrawer();
  }

  @override
  bool updateShouldNotify(GameShell oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}

class GameDrawerButton extends StatelessWidget {
  const GameDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => GameShell.open(context),
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    );
  }
}
