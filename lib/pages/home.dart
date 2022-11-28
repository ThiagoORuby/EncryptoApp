// ignore_for_file: prefer_const_constructors

import 'package:encrypto_app/pages/decrypt_page.dart';
import 'package:encrypto_app/pages/encrypt_page.dart';
import 'package:encrypto_app/pages/generate_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  late PageController pc = PageController();

  setCurrentPage(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: setCurrentPage,
        children: [GeneratePage(), EncryptPage(), DecryptPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        fixedColor: Colors.blueAccent,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.key), label: "Public keys"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.lock), label: "Encrypt"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.lock_open), label: "Decrypt")
        ],
        onTap: (page) {
          pc.animateToPage(page,
              duration: Duration(milliseconds: 400), curve: Curves.ease);
        },
      ),
    );
  }
}
