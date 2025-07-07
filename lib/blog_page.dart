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
//   final ImagePicker _picker = ImagePicker();
//   final SupabaseClient _supabase = Supabase.instance.client;

//   Future<void> _openAddDialog() async {
//     String? title;
//     String? detail;
//     File? imageFile;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Add Blog Post"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(
//                   decoration: const InputDecoration(labelText: "Title"),
//                   onChanged: (value) => title = value,
//                 ),
//                 TextField(
//                   decoration: const InputDecoration(labelText: "Detail"),
//                   onChanged: (value) => detail = value,
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final XFile? pickedImage =
//                         await _picker.pickImage(source: ImageSource.gallery);
//                     if (pickedImage != null) {
//                       imageFile = File(pickedImage.path);
//                     }
//                   },
//                   child: const Text("Pick Image"),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (title != null && detail != null && imageFile != null) {
//                   await _uploadToSupabase(title!, detail!, imageFile!);
//                   Navigator.pop(context);
//                 }
//               },
//               child: const Text("Submit"),
//             )
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _uploadToSupabase(
//       String title, String detail, File image) async {
//     try {
//       final String fileName = DateTime.now().microsecondsSinceEpoch.toString();
//       final String filePath = 'blog_images/$fileName';

//       // Upload image to Supabase Storage
//       await _supabase.storage.from('images').upload(
//             filePath,
//             image,
//             fileOptions: const FileOptions(contentType: 'image/jpeg'),
//           );

//       final String publicUrl =
//           _supabase.storage.from('blog_bucket').getPublicUrl(filePath);

//       // Insert post to Supabase Database
//       await _supabase.from('blogs').insert({
//         'title': title,
//         'detail': detail,
//         'image_url': publicUrl,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Blog uploaded successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Mini Blog")),
//       body: const Center(child: Text("Click + to add a blog post.")),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openAddDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
