import 'package:flutter/material.dart';

class EncryptPage extends StatefulWidget {
  EncryptPage({Key? key}) : super(key: key);

  @override
  State<EncryptPage> createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage> {
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
