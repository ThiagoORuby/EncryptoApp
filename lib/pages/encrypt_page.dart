// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../modules/primechecker.dart';
import 'package:file_picker/file_picker.dart';

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
  var isLoading = false;
  String crypted = "";

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

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/chave_publica.txt');
    await file.writeAsString(text);
  }

  // Modal bottom sheet
  _showMyModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Here is your crypted message: ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 36,
                  ),
                  TextField(
                    controller: TextEditingController()..text = crypted,
                    enableInteractiveSelection: true,
                    readOnly: true,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.justify,
                    keyboardType: TextInputType.multiline,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9 ]"))
                    ],
                    minLines: 1,
                    maxLines: 1000, // define o tipo de teclado utilizado
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 36,
                  ),
                  OutlinedButton(
                      onPressed: () => {_write(crypted)},
                      child: Text(
                        "Save as .txt file",
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
          );
        });
  }

  // Encrypting
  encrypting() async {
    if (_form2.currentState!.validate() && _form3.currentState!.validate()) {
      print("Funfou");
      setState(() {
        isLoading = true;
      });
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
      crypted = jsonDecode(responseBody)['crypted'];
      print(crypted);
      setState(() {
        isLoading = false;
      });
      _showMyModal();
      return resp;
    }
  }

  Future<String> _read() async {
    late String text;
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/my_file.txt');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
                        prefixIcon: Icon(Icons.message),
                      ),
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
                    (isLoading)
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox()
                  ]),
            ),
          ))),
    );
  }
}
