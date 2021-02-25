import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat and Dog Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Cat and Dog Detector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File images;
  bool isloading;
  String val;
  @override
  void initState() {
    super.initState();
    isloading=true;
    loadModel().then((val){
      setState(() {
      isloading =false;
    });
    });
  }
  Future _imagepicker() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image==null){
      image= null;
    }
    else{
    setState(() {
        isloading=false;
        images=image;
        runModeOnImage(image);
    });
    
    }
  }
  runModeOnImage(File image)async{
      isloading= true;
      var results=await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.5,
      );
      
      setState(() {
        isloading=false;
        val=results[0]["label"];
      });
  }
  loadModel()async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isloading==true ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ): Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Container(
                padding: EdgeInsets.all(5),
                child: images==null? new Text('No image selected.'):new Image.file(images),
              ),
              margin: EdgeInsets.symmetric(horizontal: 70,vertical: 70),
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
            ),  
           val==null? Text("null"):Text(val.substring(1),style: TextStyle(fontSize: 30),)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _imagepicker,
        tooltip: 'image picker',
        child: Icon(Icons.collections),
      ),
    );
  }
}
