import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imageobjectdetection/scan_controller.dart';

class ImageDetectView extends StatelessWidget {
  const ImageDetectView({super.key});

  @override
  Widget build(BuildContext context) {
    final ScanController controller = Get.put(ScanController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Image Identifier"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Obx(() {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        controller.imagePath.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(controller.imagePath.value),
                                fit: BoxFit.cover,
                              ),
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/No_Image_Available.jpg', // Make sure this image exists in your assets
                                    height: 100,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text("No image selected"),
                                ],
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                  controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Column(
                        children: [
                          const Text("Detected Image:"),
                          RichText(
                            text: TextSpan(
                              text: controller.label.value.isNotEmpty 
                                  ? controller.label.value[0].toUpperCase() // First letter capitalized
                                  : '',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 1, 47, 85),
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.label.value.length > 1
                                      ? controller.label.value.substring(1) // The rest of the text
                                      : '',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (controller.results.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: LinearProgressIndicator(
                                value: controller.results[0]['confidence'],
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Confidence: ${(controller.results[0]['confidence'] * 100).toStringAsFixed(2)}%",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]
                        ],
                      ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        onPressed: controller.captureImageFromCamera,
                        child: const Text("Camera"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        onPressed: controller.pickImageFromGallery,
                        child: const Text("Gallery"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
