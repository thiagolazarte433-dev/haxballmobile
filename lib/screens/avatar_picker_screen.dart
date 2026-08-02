import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/avatar_provider.dart';
import '../theme/app_theme.dart';

class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key});

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  File? _selectedImage;
  String? _base64Image;
  bool _processing = false;

  Future<void> _pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado. Actívalo en Ajustes del sistema.')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    setState(() => _processing = true);
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);

    setState(() {
      _selectedImage = file;
      _base64Image = base64Str;
      _processing = false;
    });
  }

  Future<void> _confirmAvatar() async {
    if (_base64Image == null) return;
    await context.read<AvatarProvider>().setAvatar(_base64Image!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar guardado. Se aplicará al entrar a una sala.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _restoreDefault() async {
    await context.read<AvatarProvider>().setAvatar('');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Avatar')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 3),
                    boxShadow: [AppTheme.neonGlow()],
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                    color: AppTheme.surfaceVariant,
                  ),
                  child: _processing
                      ? const CircularProgressIndicator(color: AppTheme.accentPink)
                      : (_selectedImage == null
                          ? const Icon(Icons.person_rounded, size: 72, color: AppTheme.textSecondary)
                          : null),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Galería'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Cámara'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _base64Image == null ? null : _confirmAvatar,
                child: const Text('Aplicar Avatar'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _restoreDefault,
              child: const Text('Restaurar avatar por defecto', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
