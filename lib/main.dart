import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  File? image1;
  String? num;
  bool flag = false;
  bool flag1 = false;
  Future<File?> filecompress(File? newfile) async {
    File? _rest;
    var dir = await getTemporaryDirectory();
    var uuid = const Uuid();
    var targetPath = dir.absolute.path + "/${uuid.v1()}image.jpeg";
    if (newfile != null) {
      _rest = await FlutterImageCompress.compressAndGetFile(
          newfile.absolute.path, targetPath,
          quality: 50);
    }
    return _rest;
  }

  Future getimage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File? newfile = File(pickedFile.path);
      var _image = await filecompress(newfile);
      print(_image);
      if (_image != null) {
        var _res1 = (_image.readAsBytesSync()).lengthInBytes;
        print((_res1 / 1024) / 1024);
      }
      setState(() {
        if (_image != null) {
          print("here");
          image1 = _image;
          flag1 = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pancard"),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (_val1) {
                          if (_val1 == null || _val1.isEmpty) {
                            return 'Please Enter Required Fields';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          num = val;
                        },
                        decoration: const InputDecoration(
                          hintText: "Enter the Pancard Number",
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: TextButton(
                            onPressed: getimage,
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 40,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (image1 != null) {
                                setState(() {
                                  flag = true;
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: const Text(
                                            "Please Select the photo to Continue"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("try_again"))
                                        ],
                                      );
                                    });
                              }
                            }
                          },
                          child: const Text("Submit")),
                    ),
                  ],
                ),
              ),
              (flag1 == true)
                  ? Column(
                      children: [
                        Image.file(
                          image1 as File,
                          height: MediaQuery.of(context).size.height / 3,
                        ),
                        (num != null)
                            ? Text(num.toString())
                            : Center(
                                child: Text(
                                  "Enter PanCard Number",
                                  style: TextStyle(color: Colors.red),
                                ),
                              )
                      ],
                    )
                  : Container()
            ],
          ),
        ));
  }
}
