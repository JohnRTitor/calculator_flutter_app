import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// A wrapper widget that allows capturing a screenshot of its child and sharing it.
class ScreenshotShareWrapper extends StatelessWidget {
  final Widget child;
  final ScreenshotController screenshotController;

  const ScreenshotShareWrapper({
    super.key,
    required this.child,
    required this.screenshotController,
  });

  @override
  Widget build(BuildContext context) {
    // The Screenshot widget wraps the content you want to capture.
    return Screenshot(
      controller: screenshotController,
      child: child,
    );
  }
}

/// Helper method to capture a screenshot using the provided [screenshotController]
/// and open the native share dialog.
Future<void> captureAndShareScreenshot({
  required BuildContext context,
  required ScreenshotController screenshotController,
  String subject = 'Check out this result!',
  String text = 'Here is the result from the Calculator app.',
}) async {
  try {
    // Show a loading indicator (optional but good for UX)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capturing screenshot...')),
    );

    // Capture the image with a small delay to ensure UI is fully rendered
    final Uint8List? imageBytes = await screenshotController.capture(
      delay: const Duration(milliseconds: 100),
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    if (imageBytes != null) {
      // Save image to temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      // Hide the snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Share the file
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(imagePath)],
        subject: subject,
        text: text,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture screenshot')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing screenshot: $e')),
      );
    }
  }
}
