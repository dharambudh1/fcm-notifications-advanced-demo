import "package:flutter/material.dart";

class Screen2 extends StatelessWidget {
  const Screen2({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen 2"),
      ),
      body: SafeArea(
        child: Center(child: Text(id)),
      ),
    );
  }
}
