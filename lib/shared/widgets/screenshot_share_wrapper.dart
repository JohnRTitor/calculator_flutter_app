import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// A wrapper widget that allows capturing a screenshot of its child and sharing it.
/// It uses a temporary opaque background during capture to ensure transparency
/// does not result in dark/black backgrounds when shared.
class ScreenshotShareWrapper extends StatefulWidget {
  final Widget child;

  const ScreenshotShareWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ScreenshotShareWrapper> createState() => ScreenshotShareWrapperState();
}

class ScreenshotShareWrapperState extends State<ScreenshotShareWrapper> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  /// Captures the wrapped child with an opaque background and opens the share dialog.
  Future<void> captureAndShare({
    String subject = 'Check out this result!',
    String text = 'Here is the result from the Calculator app.',
  }) async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capturing screenshot...')),
      );

      // 1. Switch to opaque background
      setState(() {
        _isCapturing = true;
      });

      // Allow the UI to render the opaque background
      await Future.delayed(const Duration(milliseconds: 50));

      // 2. Capture the image
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 50),
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      // 3. Revert to transparent background immediately
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(imageBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(imagePath)],
          subject: subject,
          text: text,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture screenshot')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing screenshot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: ColoredBox(
        color: _isCapturing
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        child: widget.child,
      ),
    );
  }
}
