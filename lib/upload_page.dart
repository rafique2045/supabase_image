// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class UploadPage extends StatefulWidget {
//   const UploadPage({super.key});

//   @override
//   State<UploadPage> createState() => _UploadPageState();
// }

// class _UploadPageState extends State<UploadPage> {
//   File? _imageFile;

//   //pick Image
//   Future pickImage() async {
//     final ImagePicker imagePicker = ImagePicker();
//     final XFile? image =
//         await imagePicker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       setState(() {
//         _imageFile = File(image.path);
//       });
//     }
//   }

// //Up;oad Image
//   Future uploadImage() async {
//     if (_imageFile == null) return;
//     //Genarate Unique File path
//     final fileName = DateTime.now().microsecondsSinceEpoch.toString();
//     final path = "uploads/$fileName";

//     await Supabase.instance.client.storage
//         .from('images')
//         .upload(path, _imageFile!)
//         .then((value) => ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Image Uploaded Successfully"))));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text("Upload Image"),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _imageFile != null
//               ? Image.file(_imageFile!, height: 300)
//               : Text("No Image is Selected"),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: pickImage,
//             child: Text("Pick Image"),
//           ),
//           ElevatedButton(
//             onPressed: uploadImage,
//             child: Text("Upload Image"),
//           ),
//         ],
//       ),
//     );
//   }
// }
