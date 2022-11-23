import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Model extends StatefulWidget {
  const Model({Key? key}) : super(key: key);

  @override
  State<Model> createState() => _ModelState();
}

class _ModelState extends State<Model> {
  late File _image;
  bool selImage = false;
  List result = [];

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  Future _showDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Make a choice! "),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: const Text("Gallery "),
                    onTap: () {
                      chooseImage();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: const Text("Camera "),
                    onTap: () {
                      cameraImage();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Soil Type Classification"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (selImage)
                ? Image.file(
                    _image,
                    fit: BoxFit.cover,
                  )
                : Container(),
            const SizedBox(
              height: 30,
            ),
            (result.isEmpty)
                ? Container()
                : Text(
                    (result[0]['label']).replaceAll(RegExp(r"\d+"), ""),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
            InkWell(
              onTap: () {
                _showDialog();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blueAccent,
                ),
                child: const Text(
                  "Galary",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> chooseImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // ignore: unnecessary_null_comparison
    if (image!.path != null) {
      setState(() {
        selImage = true;
        _image = File(image.path);
        Navigator.of(context).pop();
      });
    }
    predictImage(_image);
  }

  Future<void> cameraImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    // ignore: unnecessary_null_comparison
    if (image!.path != null) {
      setState(() {
        selImage = true;
        _image = File(image.path);
        Navigator.of(context).pop();
      });
    }

    predictImage(_image);
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  predictImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 5,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      result = output!;
    });
    // print("Result is: $result");
  }
}
