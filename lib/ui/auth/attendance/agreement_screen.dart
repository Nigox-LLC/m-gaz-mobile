import 'package:flutter/material.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/core/utils/style.dart';
import 'package:m_gaz/global_widget/custom_button.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:pdfx/pdfx.dart';
import 'camera_screen.dart';

class AgreementPdfScreen extends StatefulWidget {
  const AgreementPdfScreen({super.key});

  @override
  State<AgreementPdfScreen> createState() => _AgreementPdfScreenState();
}

class _AgreementPdfScreenState extends State<AgreementPdfScreen> {
  late PdfControllerPinch _controller;

  bool _isLoading = true;
  String? _error;

  bool _agreed = false;
  bool _reachedEnd = false;

  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final documentFuture = PdfDocument.openAsset('assets/agreement.pdf');

      // Sahifa sonini olish
      final document = await documentFuture;

      _controller = PdfControllerPinch(
        document: documentFuture, // ✅ TO‘G‘RI
      );

      setState(() {
        _totalPages = document.pagesCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "PDF faylni yuklashda xatolik: $e";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGlobalAppBar(
        title: "Shartnoma",
        showBack: false,
      ),
      body: _error != null
          ? Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// PDF VIEW
          Expanded(
            child: PdfViewPinch(
              controller: _controller,
              onPageChanged: (page) {
                if (page == _totalPages - 1 && !_reachedEnd) {
                  setState(() {
                    _reachedEnd = true;
                  });
                }
              },
            ),
          ),

          /// Hint
          if (!_reachedEnd)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Davom etish uchun shartnomani oxirigacha o‘qing",
                style: AppTextStyles.style400.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),

          /// Checkbox
          if (_reachedEnd)
            CheckboxListTile(
              value: _agreed,
              onChanged: (value) {
                setState(() {
                  _agreed = value ?? false;
                });
              },
              title: Text(
                "PDF shartlariga roziman",
                style: AppTextStyles.style500.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              activeColor: AppColors.c17B26A,
              controlAffinity: ListTileControlAffinity.leading,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: CustomButton(
              title: "Roziman",
              backgroundColor:
              _agreed ? AppColors.c1570EF : AppColors.cA1A8B0,
              onTap: _agreed
                  ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraScreen(),
                  ),
                );
              }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
