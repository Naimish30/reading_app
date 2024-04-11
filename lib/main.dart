
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String url="";
  int ? number;
  uploadDatatofirebase() async{
    number=Random().nextInt(10);
    FilePickerResult? result =await FilePicker.platform.pickFiles();
    File pick=File(result!.files.single.path.toString());
    var file = pick.readAsBytesSync();
    String name=DateTime.now().millisecondsSinceEpoch.toString();


    var pdfFile=FirebaseStorage.instance.ref().child(name).child("/.pdf");
    UploadTask task=pdfFile.putData(file);
    TaskSnapshot snapshot=await task;
    url =await snapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection("file").doc().set({
      'fileUrl':url,
      'num':number.toString(),
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('PDF Reader'),),
        floatingActionButton: FloatingActionButton(onPressed: uploadDatatofirebase,child: Icon(Icons.add),),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("file").snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot>snapshot){

            if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context,i) {
                  QueryDocumentSnapshot x=snapshot.data!.docs[i];
                  return InkWell(onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>view(url: x['fileUrl'],)));
                  },
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(x["num"],style: TextStyle(
                            fontSize: 30.0,
                          ),),
                        ),
                      ),);

                  }
                );
            }
          return Center(child: CircularProgressIndicator(),);
          },
        ),

    );
  }
}

class view extends StatelessWidget {

  PdfViewerController? _pdfViewerController;
 late final url;
 view({this.url});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pdf View"),
      ),
      body:SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SfPdfViewer.network(
          url,
          controller: _pdfViewerController,
        ),
      ),
    );
  }
}
