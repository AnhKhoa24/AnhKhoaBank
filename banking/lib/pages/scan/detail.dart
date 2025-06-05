import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String id;
  final String info;

  const DetailPage({
    Key? key,
    required this.id,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết mã QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: $id',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Info: $info',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            // Nếu muốn nút quay lại
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Quay về quét'),
            ),
          ],
        ),
      ),
    );
  }
}
