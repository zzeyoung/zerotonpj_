import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  bool _isLoading = false;

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

  Future<void> _uploadProof() async {
    if (_image == null || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('이미지와 인증 내용을 모두 입력해야 합니다.'),
      ));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final uniqueFileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final storageRef =
          FirebaseStorage.instance.ref().child('proofs/$uniqueFileName');

      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final imageUrl = await snapshot.ref.getDownloadURL();

      final proofDoc =
          await FirebaseFirestore.instance.collection('proofs').add({
        'userID': userId,
        'challengeID': widget.challengeId,
        'content': _contentController.text,
        'image_url': imageUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      final proofId = proofDoc.id;

      final response = await http.patch(
        Uri.parse('http://10.0.2.2:3000/proofs/$proofId/approve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'challengeId': widget.challengeId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 인증 성공! 포인트가 적립되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ 인증 저장은 성공했지만 포인트 적립 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🚨 업로드 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        title: const Text('인증 업로드'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'assets/earth.png', // 이미지 경로
              height: 170,
            ),
            const SizedBox(height: 8),
            const Text(
              '오늘도 지구를 위한 실천 성공!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 이미지 선택 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD4A9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '이미지 선택',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 인증 업로드 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20A17B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '인증 업로드',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 이미지 미리보기
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),

            // 인증 내용 타이틀
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '인증 내용',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 인증 내용 입력창
            TextField(
              controller: _contentController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '인증 내용을 입력하세요',
                border: const UnderlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
