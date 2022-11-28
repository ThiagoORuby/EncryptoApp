// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../modules/primechecker.dart';

class GeneratePage extends StatefulWidget {
  GeneratePage({Key? key}) : super(key: key);

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final _form1 = GlobalKey<FormState>();
  final _valor1 = TextEditingController();
  final _form2 = GlobalKey<FormState>();
  final _valor2 = TextEditingController();
  final _form3 = GlobalKey<FormState>();
  final _valor3 = TextEditingController();
  var _isLoading = false;
  var texto = '';
  Map<String, dynamic> keys = {};

  primeValidate(value) {
    if (value!.isEmpty) {
      return "Empty field";
    } else if (isPrime(BigInt.parse(value)) == 0) {
      return "The value is not a prime number";
    } else {
      return null;
    }
  }

  coprimeValidate(value) {
    if (value!.isEmpty) {
      //print(BigInt.parse(_valor1.text));
      //print(BigInt.parse(_valor2.text));
      return "Empty field";
    } else if (_valor1.text.isEmpty || _valor2.text.isEmpty) {
      return "fill the prime numbers fields";
    } else if (_valor1.text.length > 30 || _valor2.text.length > 30) {
      return null;
    } else if (mdc(
            BigInt.parse(value),
            (BigInt.parse(_valor1.text) - BigInt.one) *
                (BigInt.parse(_valor2.text) - BigInt.one)) !=
        BigInt.one) {
      return "The value is not a coprime number";
    } else {
      return null;
    }
  }

  primeInput(String placeholder, final form, final valor, int isCoprime) {
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
            return (isCoprime == 1)
                ? coprimeValidate(value)
                : primeValidate(value);
          },
        ));
  }

  // PopUp
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failed to connect!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Check your internet connection and try again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/chave_publica.txt');
    await file.writeAsString(text);
  }

  _read() async {
    String text = '';
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/chave_publica.txt');
      text = await file.readAsString();
      print("to aqui");
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  // Generate key
  generate_key() async {
    if (_form1.currentState!.validate() &&
        _form2.currentState!.validate() &&
        _form3.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      print("Funfou");
      print(mdc(BigInt.from(2), BigInt.from(12 * 16)) == BigInt.one);
      //print(isPrime(221));
      final uri = 'https://encrypto-api-com.onrender.com/generate_key';
      Map<String, String> data = {
        "p": _valor1.text,
        "q": _valor2.text,
        "e": _valor3.text
      };
      print(data);
      try {
        http.Response resp = await http.post(Uri.parse(uri),
            body: jsonEncode(data),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
        int statusCode = resp.statusCode;
        String responseBody = resp.body;
        print(statusCode);
        print(responseBody);
        keys = jsonDecode(responseBody);
        _write("${keys['n']}, ${keys['e']}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Saving public keys in 'chaves.txt'")));
      } catch (e) {
        _showMyDialog();
      }
      setState(() {
        _isLoading = false;
      });
      //_showMyDialog();
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(title: Text("Generate Public Key")),
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
                        "Choose 2 prime numbers (p and q) and another number (e) which is coprime with (p - 1) x (q - 1)",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                    SizedBox(
                      height: 36,
                    ),
                    primeInput("Type a prime number p", _form1, _valor1, 0),
                    SizedBox(
                      height: 36,
                    ),
                    primeInput("Type a prime number q", _form2, _valor2, 0),
                    SizedBox(
                      height: 36,
                    ),
                    primeInput("Type the e value", _form3, _valor3, 1),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(top: 24),
                      child: ElevatedButton(
                          onPressed: (() {
                            generate_key();
                          }),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              Icon(Icons.key),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Generate Keys',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    (_isLoading)
                        ? Center(child: CircularProgressIndicator())
                        : (keys.isEmpty)
                            ? SizedBox()
                            : Center(
                                child: ListBody(
                                children: [
                                  SelectableText(
                                      "Your n value is: ${keys['n']}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  SelectableText(
                                      "Your e value is: ${keys['e']}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold))
                                ],
                              ))
                  ]),
            ),
          ))),
    );
  }
}
