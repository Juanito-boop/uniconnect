import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MediaAttachmentWidget extends StatefulWidget {
  final List<XFile> selectedImages;
  final Function(List<XFile>) onImagesChanged;

  const MediaAttachmentWidget({
    Key? key,
    required this.selectedImages,
    required this.onImagesChanged,
  }) : super(key: key);

  @override
  State<MediaAttachmentWidget> createState() => _MediaAttachmentWidgetState();
}

class _MediaAttachmentWidgetState extends State<MediaAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras!.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras!.first)
            : _cameras!.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras!.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();
        await _applySettings();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      // Silent fail - camera not available
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      final updatedImages = List<XFile>.from(widget.selectedImages)..add(photo);
      widget.onImagesChanged(updatedImages);

      setState(() {
        _showCamera = false;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final updatedImages = List<XFile>.from(widget.selectedImages)
          ..addAll(images);
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _openCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (hasPermission && _isCameraInitialized) {
      setState(() {
        _showCamera = true;
      });
    }
  }

  void _removeImage(int index) {
    final updatedImages = List<XFile>.from(widget.selectedImages)
      ..removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedImages = List<XFile>.from(widget.selectedImages);
    final item = updatedImages.removeAt(oldIndex);
    updatedImages.insert(newIndex, item);
    widget.onImagesChanged(updatedImages);
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera && _isCameraInitialized && _cameraController != null) {
      return _buildCameraView();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Adjuntar medios',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: CustomIconWidget(
                    iconName: 'photo_library',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: Text('Galería'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCameraInitialized ? _openCamera : null,
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Cámara'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
          if (widget.selectedImages.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              '${widget.selectedImages.length} imagen${widget.selectedImages.length > 1 ? 'es' : ''} seleccionada${widget.selectedImages.length > 1 ? 's' : ''}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 20.h,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedImages.length,
                onReorder: _reorderImages,
                itemBuilder: (context, index) {
                  final image = widget.selectedImages[index];
                  return Container(
                    key: ValueKey(image.path),
                    margin: EdgeInsets.only(right: 2.w),
                    child: Stack(
                      children: [
                        Container(
                          width: 30.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(
                                    image.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppTheme
                                            .lightTheme.colorScheme.surface,
                                        child: Center(
                                          child: CustomIconWidget(
                                            iconName: 'image',
                                            color: AppTheme
                                                .lightTheme.colorScheme.outline,
                                            size: 24,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(image.path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppTheme
                                            .lightTheme.colorScheme.surface,
                                        child: Center(
                                          child: CustomIconWidget(
                                            iconName: 'image',
                                            color: AppTheme
                                                .lightTheme.colorScheme.outline,
                                            size: 24,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 1.w,
                          right: 1.w,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: AppTheme.lightTheme.colorScheme.onError,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 1.w,
                          left: 1.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomIconWidget(
                              iconName: 'drag_handle',
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),
            Positioned(
              top: 2.h,
              left: 4.w,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCamera = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4.h,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
