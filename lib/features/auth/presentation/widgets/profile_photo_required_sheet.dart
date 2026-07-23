import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/ui/auth/attendance/camera_screen.dart';

Future<File?> showProfilePhotoRequiredDialog(BuildContext context) {
  return showDialog<File>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const ProfilePhotoRequiredDialog(),
  );
}

class ProfilePhotoRequiredDialog extends StatefulWidget {
  const ProfilePhotoRequiredDialog({super.key});

  @override
  State<ProfilePhotoRequiredDialog> createState() =>
      _ProfilePhotoRequiredDialogState();
}

class _ProfilePhotoRequiredDialogState
    extends State<ProfilePhotoRequiredDialog> {
  final _imagePicker = ImagePicker();
  File? _selectedPhoto;

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<_ProfilePhotoSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ProfilePhotoSourceSheet(),
    );
    if (source == null || !mounted) return;

    final File? photo;
    if (source == _ProfilePhotoSource.camera) {
      photo = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (_) => const CameraScreen(forProfilePhoto: true),
        ),
      );
    } else {
      photo = await _pickGalleryPhoto();
    }

    if (photo != null && mounted) setState(() => _selectedPhoto = photo);
  }

  void _confirmPhoto() {
    final photo = _selectedPhoto;
    if (photo != null) Navigator.pop(context, photo);
  }

  Future<File?> _pickGalleryPhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;

    final detector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
    try {
      final faces = await detector.processImage(
        InputImage.fromFilePath(image.path),
      );
      if (faces.isEmpty) {
        if (mounted) showToast(context, Words.faceNotFound.tr());
        return null;
      }
      return File(image.path);
    } finally {
      await detector.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Words.profilePhotoRequired.tr(),
                  key: const Key('profile-photo-required-title'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF1A1D2E),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 24 / 20,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD0D5E2),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _selectedPhoto == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 30,
                              color: Color(0xFF1A1D2E),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Words.uploadPhoto.tr(),
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFBBBBBB),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 20 / 13,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Image.file(
                            _selectedPhoto!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    key: const Key('profile-photo-upload-button'),
                    onPressed: _selectedPhoto == null
                        ? _choosePhoto
                        : _confirmPhoto,
                    icon: const Icon(Icons.upload_outlined, size: 24),
                    label: Text(Words.upload.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF314692),
                      foregroundColor: const Color(0xFFFCFCFC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 24 / 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ProfilePhotoSource { camera, gallery }

class _ProfilePhotoSourceSheet extends StatelessWidget {
  const _ProfilePhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SourceTile(
              icon: Icons.camera_alt_outlined,
              label: Words.openCamera.tr(),
              onTap: () => Navigator.pop(context, _ProfilePhotoSource.camera),
            ),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: Words.uploadFromPhone.tr(),
              onTap: () => Navigator.pop(context, _ProfilePhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF1A1D2E)),
      title: Text(
        label,
        style: GoogleFonts.manrope(
          color: const Color(0xFF1A1D2E),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: onTap,
    );
  }
}
