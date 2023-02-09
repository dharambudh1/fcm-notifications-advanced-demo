import "package:flutter/material.dart";

class Screen1 extends StatelessWidget {
  const Screen1({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen 1"),
      ),
      body: SafeArea(
        child: Center(child: Text(id)),
      ),
    );
  }
}
