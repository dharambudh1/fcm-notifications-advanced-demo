import "package:flutter/material.dart";

class Screen3 extends StatelessWidget {
  const Screen3({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen 3"),
      ),
      body: SafeArea(
        child: Center(child: Text(id)),
      ),
    );
  }
}
