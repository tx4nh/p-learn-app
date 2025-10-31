import 'package:flutter/material.dart';

class ProfileEditableInfoTile extends StatelessWidget {
  const ProfileEditableInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEditing,
    required this.controller,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEditing;
  final TextEditingController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.red.shade600, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      subtitle: isEditing
          ? TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              autofocus: true,
            )
          : Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
      trailing: IconButton(
        icon: Icon(isEditing ? Icons.check : Icons.edit),
        color: Colors.red.shade600,
        onPressed: onPressed,
      ),
    );
  }
}