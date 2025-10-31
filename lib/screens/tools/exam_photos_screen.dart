import 'package:flutter/material.dart';
import 'full_screen_image_viewer.dart'; 

class ExamPhotosScreen extends StatelessWidget {
  final String subject;
  final List<String> examImageUrls;

  const ExamPhotosScreen({super.key, required this.subject, required this.examImageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Colors.red,
      ),
      body: examImageUrls.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Chưa có đề thi cho môn học này. Vui lòng quay lại sau.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                mainAxisSpacing: 10.0,
              ),
              itemCount: examImageUrls.length,
              itemBuilder: (context, index) {
                final imagePath = examImageUrls[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell( 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(imagePath: imagePath),
                        ),
                      );
                    },
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
