import 'package:flutter/material.dart';

class DecryptPage extends StatefulWidget {
  DecryptPage({Key? key}) : super(key: key);

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
      "hello world 2",
      style: TextStyle(color: Colors.black),
    )));
  }
}
