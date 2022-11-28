// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../modules/primechecker.dart';

class DecryptPage extends StatefulWidget {
  DecryptPage({Key? key}) : super(key: key);

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  final _valor0 = TextEditingController();
  final _form1 = GlobalKey<FormState>();
  final _valor1 = TextEditingController();
  final _form2 = GlobalKey<FormState>();
  final _valor2 = TextEditingController();
  final _form3 = GlobalKey<FormState>();
  final _valor3 = TextEditingController();
  var isLoading = false;
  var decrypted = '';

  primeValidate(value) {
    if (value!.isEmpty) {
      return "Empty field";
    } else if (value.length > 30) {
      return null;
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
      print("Tamanho: ${_valor1.text.length}");
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

  _write(String text, context) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/mensagem_decriptada.txt');
    await file.writeAsString(text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Saving decrypted message in 'mensagem_decriptada.txt'")));
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
                  Text("Here is your decrypted message: ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 36,
                  ),
                  TextField(
                    controller: TextEditingController()..text = decrypted,
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
                      onPressed: () => {_write(decrypted, context)},
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
    if (_form2.currentState!.validate() &&
        _form3.currentState!.validate() &&
        _form1.currentState!.validate()) {
      print("Funfou");
      setState(() {
        isLoading = true;
      });
      final uri = 'https://encrypto-api-com.onrender.com/decrypting';
      Map<String, dynamic> data = {
        "crypted": _valor0.text,
        "p": _valor1.text,
        "q": _valor2.text,
        "e": _valor3.text
      };
      print(data);
      try {
        http.Response resp = await http.post(Uri.parse(uri),
            body: json.encode(data),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
        int statusCode = resp.statusCode;
        String responseBody = resp.body;
        print(statusCode);
        print(responseBody);

        if (statusCode != 200) {
          decrypted =
              "There are something wrong with your keys or crypted message";
        } else {
          decrypted = jsonDecode(responseBody)['message'];
        }
        _showMyModal();
      } catch (e) {
        _showMyDialog();
      }
      setState(() {
        isLoading = false;
      });
      return 1;
    }
  }

  // pick a file
  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String texto = await file.readAsString();
      print(texto);
      setState(() {
        _valor0.text = texto;
      });
    } else {
      print("No file selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(title: Text("Decrypting A Message")),
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
                        "Choose a crypted message to be decrypted and type the RSA private keys values",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                    SizedBox(
                      height: 36,
                    ),
                    TextField(
                      controller: _valor0,
                      style: TextStyle(fontSize: 18),
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9 ]"))
                      ],
                      minLines: 1,
                      maxLines: 10, // define o tipo de teclado utilizado
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Type a crypted message to decrypt",
                          prefixIcon: Icon(Icons.message),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.file_open,
                            ),
                            onPressed: () => {pickFile()},
                          )),
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    primeInput("Type the p value", _form1, _valor1, 0),
                    SizedBox(
                      height: 36,
                    ),
                    primeInput("Type the q value", _form2, _valor2, 0),
                    SizedBox(
                      height: 36,
                    ),
                    primeInput("Type the e value", _form3, _valor3, 1),
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
                              Icon(Icons.lock_open_rounded),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Decrypting',
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
