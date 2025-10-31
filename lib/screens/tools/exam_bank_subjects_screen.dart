import 'package:flutter/material.dart';
import 'dart:math'; // For Random
import 'exam_photos_screen.dart';

class ExamBankSubjectsScreen extends StatefulWidget {
  const ExamBankSubjectsScreen({super.key});

  @override
  State<ExamBankSubjectsScreen> createState() => _ExamBankSubjectsScreenState();
}

class _ExamBankSubjectsScreenState extends State<ExamBankSubjectsScreen> {
  // Dummy data for subjects
  final List<String> _subjects = const [
    'Giải tích 1',
    'Đại số tuyến tính',
    'Vật lý 1',
    'Lập trình C++',
    'Kiến trúc máy tính',
    'Mạng máy tính',
    'Cơ sở dữ liệu',
    'Hệ điều hành',
  ];

  final List<String> _allImages = [
    'assets/images/363493307_885003469850187_1260185199131880069_n.png',
    'assets/images/393159031_330650836429026_700909580998953925_n.png',
    'assets/images/403604072_1067609571035918_7007985416973425343_n.png',
    'assets/images/410394862_868184091974516_7785942231456586866_n.png',
    'assets/images/551723359_1333325174894230_4832985075880308900_n.png',
    'assets/images/553779913_1340513411117343_2398158787860127222_n.png',
    'assets/images/569936382_808879698722048_5881605634348290566_n.png',
    'assets/images/575208365_1364237815062991_6684399816032486014_n.png',
  ];

  late List<List<String>> _subjectImages;

  @override
  void initState() {
    super.initState();
    _assignImagesRandomly();
  }

  void _assignImagesRandomly() {
    final random = Random();
    final shuffledImages = List<String>.from(_allImages)..shuffle(random);
    
    // Since we have 8 images and 8 subjects, we assign one to each.
    // If there were more images, we could assign more.
    _subjectImages = List.generate(_subjects.length, (index) {
      if (shuffledImages.isNotEmpty) {
        return [shuffledImages.removeAt(0)];
      }
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân hàng đề thi'),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final imagesForSubject = _subjectImages[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamPhotosScreen(
                      subject: subject,
                      examImageUrls: imagesForSubject,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
