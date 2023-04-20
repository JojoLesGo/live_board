import 'package:flutter/material.dart';

class NiceButton extends StatelessWidget{
  const NiceButton({required this.child, required this.onClick});
  final Widget child;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) => TextButton(
    style: TextButton.styleFrom(
      side: const BorderSide(color: Colors.red)
    ),
    onPressed: onClick,
    child: child,
  );
}