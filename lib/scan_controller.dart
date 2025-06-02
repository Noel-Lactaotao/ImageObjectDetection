import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class ScanController extends GetxController {
  var label = "".obs;
  var imagePath = "".obs;
  var results = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadModel();
  }

  @override
  void onClose() {
    Tflite.close();
    super.onClose();
  }

  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      print("Model loaded: $res");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      await runInference(File(pickedFile.path));
    }
  }

  Future<void> captureImageFromCamera() async {
    final XFile? capturedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (capturedFile != null) {
      imagePath.value = capturedFile.path;
      await runInference(File(capturedFile.path));
    }
  }

  Future<void> runInference(File imageFile) async {
    isLoading.value = true;
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 1,
        threshold: 0.1,
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        final safeResults = recognitions
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (safeResults.isNotEmpty) {
          label.value = safeResults[0]['label'] ?? "No label";
          results.value = safeResults;
        } else {
          label.value = "No valid result";
          results.clear();
        }
      } else {
        label.value = "No result";
        results.clear();
      }
    } catch (e) {
      label.value = "Inference failed: $e";
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
