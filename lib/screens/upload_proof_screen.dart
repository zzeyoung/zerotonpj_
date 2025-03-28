import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UploadProofScreen extends StatefulWidget {
  final String challengeId;

  const UploadProofScreen({super.key, required this.challengeId});

  @override
  State<UploadProofScreen> createState() => _UploadProofScreenState();
}

class _UploadProofScreenState extends State<UploadProofScreen> {
  final _contentController = TextEditingController();
  File? _image;
  final _picker = ImagePicker();

  // ✅ 이미지 선택 기능 보완
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 선택되지 않았습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류 발생: $e')),
      );
    }
  }

  // 이미지 업로드 및 Firestore에 저장
  Future<void> _uploadProof() async {
    if (_image == null || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('이미지와 인증 내용을 모두 입력해야 합니다.'),
      ));
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Storage 업로드
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('proofs/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Firestore 저장
      await FirebaseFirestore.instance.collection('proofs').add({
        'userID': userId,
        'challengeID': widget.challengeId,
        'content': _contentController.text,
        'image_url': imageUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 인증이 업로드되었습니다!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🚨 업로드 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증 업로드')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('이미지 선택'),
            ),
            const SizedBox(height: 12),
            _image != null
                ? Image.file(_image!,
                    height: 200, width: double.infinity, fit: BoxFit.cover)
                : const Text('선택된 이미지가 없습니다.',
                    style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: '인증 내용',
                hintText: '인증 내용을 입력하세요',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProof,
              child: const Text('인증 업로드'),
            ),
          ],
        ),
      ),
    );
  }
}
