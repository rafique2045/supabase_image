import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? studentInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
  }

  Future<void> fetchStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('student_id');

    if (studentId != null) {
      final response = await Supabase.instance.client
          .from('student_info')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          studentInfo = response;
          isLoading = false;
        });
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_id');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Page'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentInfo == null
          ? const Center(child: Text('No student info found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            InfoTile(label: 'Name', value: studentInfo!['student_name']),
            InfoTile(label: 'Department', value: studentInfo!['department']),
            InfoTile(label: 'Gender', value: studentInfo!['gender']),
            InfoTile(label: 'Session', value: studentInfo!['session']),
            InfoTile(label: 'Student ID', value: studentInfo!['student_id']),
            InfoTile(label: 'Birth Date', value: studentInfo!['birth_date']),
            InfoTile(label: 'Blood Group', value: studentInfo!['blood']),
            InfoTile(label: 'Admission Date', value: studentInfo!['admission_date']),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final  label;
  final  value;

  const InfoTile({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label.toString()),
        subtitle: Text(value.toString()),
      ),
    );
  }
}
