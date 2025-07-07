import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_image/login_page.dart';

import 'auth_page.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> blogs = [

  ];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_id');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );
  }

  Future<void> _fetchBlogs() async {
    setState(() => isLoading = true);
    try {
      final response = await _supabase
          .from('blogs')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        blogs = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch blogs: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openAddDialog() async {
    String? title;
    String? detail;
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Blog Post"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Title"),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Detail"),
                  onChanged: (value) => detail = value,
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final XFile? pickedImage =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      imageFile = File(pickedImage.path);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Image selected")),
                      );
                    }
                  },
                  child: const Text("Pick Image"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (title != null && detail != null && imageFile != null) {
                  await _uploadToSupabase(title!, detail!, imageFile!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required.")),
                  );
                }
              },
              child: const Text("Submit"),
            )
          ],
        );
      },
    );
  }

  Future<void> _uploadToSupabase(
      String title, String detail, File image) async {
    try {
      final String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final String filePath = 'blog_images/$fileName';

      // Upload image to correct bucket
      await _supabase.storage.from('images').upload(
            filePath,
            image,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final String publicUrl =
          _supabase.storage.from('images').getPublicUrl(filePath);

      // Insert blog post into DB
      await _supabase.from('blogs').insert({
        'title': title,
        'detail': detail,
        'image_url': publicUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog uploaded successfully!')),
      );

      _fetchBlogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? profileName =
        FirebaseAuth.instance.currentUser?.displayName.toString();
    final profileImage = FirebaseAuth.instance.currentUser?.photoURL;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Blog"),
        actions: [
          Text("$profileName"),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profileImage.toString()),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) => LoginPage()));

              logout(context);


            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blogs.isEmpty
              ? const Center(child: Text("No blogs yet. Add one!"))
              : ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    return BlogCard(
                      title: blog['title'],
                      detail: blog['detail'],
                      imageUrl: blog['image_url'],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  const BlogCard({
    super.key,
    required this.title,
    required this.detail,
    required this.imageUrl,
  });
  final String title;
  final String detail;
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                collapsed: Text(
                  detail,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          detail,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        )),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

// Container(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   blog['title'] ?? '',
//                                   style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   maxLines: 3,
//                                   softWrap: true,
//                                   blog['detail'] ?? '',
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {},
//                                   child: Text(
//                                     "Read more",
//                                     style: TextStyle(color: Colors.black),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
