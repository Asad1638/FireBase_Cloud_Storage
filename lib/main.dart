import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  File? selectedFile;
  File? downloadedFile;
  List<String> uploadedFiles = [];
  String taskStatus = '';

  Future<void> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
       // allowedExtensions: ['pdf', 'doc', 'docx', 'pptx'],
      );

      if (result != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
          taskStatus = 'Uploading file...';
          downloadedFile = null;
        });

        Reference reference = storage
            .ref()
            .child('documents')
            .child(selectedFile!.path.split('/').last);
        UploadTask uploadTask = reference.putFile(selectedFile!);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double percentage =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          setState(() {
            taskStatus = 'Uploading file... ${percentage.toStringAsFixed(1)}%';
          });
        });

        await uploadTask.whenComplete(() {
          setState(() {
            taskStatus = 'File uploaded successfully!';
            uploadedFiles.add(selectedFile!.path.split('/').last);
          });
        });
      } else {
        // User canceled the picker
        setState(() {
          taskStatus = 'File selection canceled.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File selection canceled.'),
          ),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
      setState(() {
        taskStatus = 'Error uploading file: $e';
      });
    }
  }

  Future<void> downloadFile(String fileName) async {
    try {
      Reference reference = storage.ref().child('documents').child(fileName);

      Directory tempDir = await getTemporaryDirectory();
      downloadedFile = File('${tempDir.path}/$fileName');

      TaskSnapshot task = await reference.writeToFile(downloadedFile!);
      await OpenFile.open(downloadedFile!.path);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white ,
      appBar: AppBar(backgroundColor: Colors.grey,
        title: Text('Firebase Storage '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text('Upload Document to Firebase Storage'),
            ),
            ElevatedButton(
              onPressed: () {
                // Show a dialog and in the dialog it display a list...........................
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shadowColor:const Color.fromARGB(255, 58, 150, 236),
                      surfaceTintColor: Colors.blueGrey,
                      backgroundColor: Colors.grey[360],
                      title: const Text('Uploaded Documents'),
                      content: Container(
                        width: double.minPositive,
                        child: ListView.builder(
                          itemCount: uploadedFiles.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(leading: Icon(Icons.circle,color: Colors.blue,),
                              title: Text(uploadedFiles[index]),
                              onTap: () {
                                downloadFile(uploadedFiles[index]);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text('List Uploaded Documents'),
            ),
            const SizedBox(height: 20),
            Text('Task Status: $taskStatus'),
            if (downloadedFile != null) SfPdfViewer.file(downloadedFile!),
          ],
        ),
      ),
    );
  }
}






























// import 'dart:convert';
// import 'dart:ffi';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:data_base_fire_base/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   late Reference baseRefrence ;
//   late Reference imageRefrence;
//   Widget?image;
//   @override
//   void initState() {
  
//     super.initState();
//     baseRefrence = FirebaseStorage.instance.ref();
//     imageRefrence = baseRefrence.child('asad').child('images');
//   }

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {


//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//            if(image!=null)
//            image!
//           ],
//         ),
//       ),
//       floatingActionButton: ButtonBar(children: [
//         FloatingActionButton(
//         onPressed: ()async{
// final file =await ImagePicker().pickImage(source: ImageSource.gallery);
// if (file!=null) {
//   Uint8List bytes = await file.readAsBytes();
//   (await imageRefrence.putData(bytes))!;
// }
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),

//       FloatingActionButton(
//         onPressed: ()async{
// Uint8List bit = (await imageRefrence.getData())!;
// image = Image.memory(bit);
// setState(() {
  
// });
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//       ],)

      
//     );
//   }
// }

/***
 * 
 *  final task = imageRefrence.putData(bytes);
  task.snapshotEvents.listen((event) { 
  *  if(event.state == TaskState.running){
   *   setState(() {
     *   
    *  });
 */