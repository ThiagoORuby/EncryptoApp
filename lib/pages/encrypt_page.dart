// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../modules/primechecker.dart';

class EncryptPage extends StatefulWidget {
  EncryptPage({Key? key}) : super(key: key);

  @override
  State<EncryptPage> createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage> {
  final _valor1 = TextEditingController();
  final _form2 = GlobalKey<FormState>();
  final _valor2 = TextEditingController();
  final _form3 = GlobalKey<FormState>();
  final _valor3 = TextEditingController();
  Map<String, dynamic> keys = {};

  primeInput(String placeholder, final form, final valor) {
    return Form(
        key: form,
        child: TextFormField(
          controller: valor,
          style: TextStyle(fontSize: 18),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType:
              TextInputType.number, // define o tipo de teclado utilizado
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: placeholder,
              prefixIcon: Icon(Icons.numbers)),
          validator: (value) {
            if (value!.isEmpty) {
              return "campo vazio";
            } else {
              return null;
            }
          },
        ));
  }

  // Encrypting
  encrypting() async {
    if (_form2.currentState!.validate() && _form3.currentState!.validate()) {
      print("Funfou");
      final uri = 'https://encrypto-api-com.onrender.com/encrypting';
      Map<String, dynamic> data = {
        "message": _valor1.text,
        "n": int.parse(_valor2.text),
        "e": int.parse(_valor3.text)
      };
      print(data);
      http.Response resp = await http.post(Uri.parse(uri),
          body: json.encode(data),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      int statusCode = resp.statusCode;
      String responseBody = resp.body;
      print(statusCode);
      print(responseBody);
      keys = jsonDecode(responseBody);
      //_showMyDialog();
      return resp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Encrypting A Message")),
        body: Form(
            child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                      "Choose a message to be encrypt and put it with the RSA public key values",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center),
                  SizedBox(
                    height: 36,
                  ),
                  TextField(
                    controller: _valor1,
                    style: TextStyle(fontSize: 18),
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                    ],
                    minLines: 1,
                    maxLines: 10, // define o tipo de teclado utilizado
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Type a message to encrypt",
                        prefixIcon: Icon(Icons.message)),
                  ),
                  SizedBox(
                    height: 36,
                  ),
                  primeInput("Type the n value", _form2, _valor2),
                  SizedBox(
                    height: 36,
                  ),
                  primeInput("Type the e value", _form3, _valor3),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                        onPressed: (() {
                          print("oi");
                          encrypting();
                        }),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            Icon(Icons.lock),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Encrypting',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                ]),
          ),
        )));
  }
}
