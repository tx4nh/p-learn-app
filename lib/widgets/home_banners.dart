import 'package:flutter/material.dart';
import 'package:p_learn_app/widgets/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeBanners extends StatelessWidget {
  const HomeBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.8, // Adjust as needed for desired banner size
          children: [
            _buildBannerCard(
              context,
              title: 'Thư viện',
              icon: Icons.local_library,
              color: Colors.red.shade700,
              onTap: () async {
                final Uri url = Uri.parse('https://dlib.ptit.edu.vn/');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            _buildBannerCard(
              context,
              title: 'Quản lý đào tạo',
              icon: Icons.school,
              color: Colors.red.shade700,
              onTap: () async {
                final Uri url = Uri.parse('https://qldt.ptit.edu.vn/#/home');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            _buildBannerCard(
              context,
              title: 'Ngân hàng đề thi',
              icon: Icons.assignment,
              color: Colors.red.shade700,
              onTap: () async {
                final Uri url = Uri.parse('https://qldt.ptit.edu.vn/#/home');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            _buildBannerCard(
              context,
              title: 'Slink PTIT',
              icon: Icons.link,
              color: Colors.red.shade700,
              onTap: () async {
                final Uri url = Uri.parse('https://slink.ptit.edu.vn/');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, {required String title, required IconData icon, required Color color, VoidCallback? onTap}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 36,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
