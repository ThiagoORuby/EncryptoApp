// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
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
            } else if (isPrime(int.parse(value)) == 0) {
              return "O valor não é primo";
            } else {
              return null;
            }
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
          title: const Text('Here are your public keys!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                SelectableText("n = 113 e = 5", style: TextStyle(fontSize: 20))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Generate key
  generate_key() async {
    if (_form1.currentState!.validate() && _form2.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      print("Funfou");
      final uri = 'https://encrypto-api-com.onrender.com/generate_key';
      Map<String, int> data = {
        "p": int.parse(_valor1.text),
        "q": int.parse(_valor2.text),
        "e": int.parse(_valor3.text)
      };
      http.Response resp = await http.post(
          Uri.parse('https://encrypto-api.herokuapp.com/generate_key'),
          body: json.encode(data),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      int statusCode = resp.statusCode;
      String responseBody = resp.body;
      print(statusCode);
      print(responseBody);
      keys = jsonDecode(responseBody);
      setState(() {
        _isLoading = false;
      });
      //_showMyDialog();
      return resp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "Choose 2 prime numbers (p and q) and another number (e) who is coprime with (p - 1) x (q - 1)",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center),
                  SizedBox(
                    height: 36,
                  ),
                  primeInput("Digite um primo p", _form1, _valor1),
                  SizedBox(
                    height: 36,
                  ),
                  primeInput("Digite um primo q", _form2, _valor2),
                  SizedBox(
                    height: 36,
                  ),
                  primeInput("Digite um valor e", _form3, _valor3),
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
                              child: SelectableText(
                                  "n = ${keys['n']}, e = ${keys['e']}",
                                  style: TextStyle(fontSize: 22)))
                ]),
          ),
        )));
  }
}
