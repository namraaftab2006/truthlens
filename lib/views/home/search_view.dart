import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/news_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/news_card.dart';
import 'shimmer_loader.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isImageProcessing = false;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<NewsController>(context, listen: false);
    controller.fetchTopHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NewsController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(controller),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: 'Search any topic...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.cardColor,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: theme.iconTheme.color),
                              onPressed: () {
                                _searchController.clear();
                                controller.fetchTopHeadlines();
                                setState(() {});
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.search,
                                color: theme.colorScheme.primary),
                            onPressed: () => _performSearch(controller),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.primary, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.camera_alt,
                      color: theme.colorScheme.primary, size: 28),
                  tooltip: 'Search from image',
                  onPressed: _isImageProcessing
                      ? null
                      : () => _showImageSourceDialog(controller),
                ),
              ],
            ),
          ),
          if (_isImageProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: controller.isLoading
                ? const ShimmerLoader()
                : controller.newsList.isEmpty
                ? Center(
              child: Text(
                'No news found. Try searching something else!',
                style: TextStyle(color: theme.hintColor),
              ),
            )
                : ListView.builder(
              itemCount: controller.newsList.length,
              itemBuilder: (context, index) {
                final article = controller.newsList[index];
                return NewsCard(article: article);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(NewsController controller) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      controller.fetchNews(query: query);
    } else {
      controller.fetchTopHeadlines();
    }
  }

  void _showImageSourceDialog(NewsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, size: 28),
                title: Text("Capture from Camera",
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndRecognizeText(controller, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, size: 28),
                title: Text("Pick from Gallery",
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndRecognizeText(controller, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  Future<void> _pickAndRecognizeText(
      NewsController controller, ImageSource source) async {
    try {
      final hasPermission = await _checkAndRequestPermissions(source);
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to access image.")),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      final file = File(image.path);
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load image.")),
        );
        return;
      }

      setState(() => _isImageProcessing = true);

      final inputImage = InputImage.fromFile(file);
      final textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (recognizedText.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No readable text found in image.")),
        );
        return;
      }

      final selectedText = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TextSelectionScreen(
            imageFile: file,
            recognizedText: recognizedText,
          ),
        ),
      );

      if (selectedText != null && selectedText.toString().trim().isNotEmpty) {
        await _showEditDialog(selectedText, controller);
      }
    } catch (e) {
      debugPrint("Error reading text: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to process image: $e")),
      );
    } finally {
      setState(() => _isImageProcessing = false);
    }
  }

  Future<void> _showEditDialog(
      String extractedText, NewsController controller) async {
    final editController = TextEditingController(text: extractedText);

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit & Search',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: TextField(
            controller: editController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Edit your search text here",
              hintStyle: TextStyle(color: theme.hintColor),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _searchController.text = editController.text.trim();
                _performSearch(controller);
              },
              icon: const Icon(Icons.search),
              label: const Text("Search"),
            ),
          ],
        );
      },
    );
  }
}

// -------------------- TEXT SELECTION VIEW --------------------

class TextSelectionScreen extends StatefulWidget {
  final File imageFile;
  final RecognizedText recognizedText;

  const TextSelectionScreen({
    super.key,
    required this.imageFile,
    required this.recognizedText,
  });

  @override
  State<TextSelectionScreen> createState() => _TextSelectionScreenState();
}

class _TextSelectionScreenState extends State<TextSelectionScreen>
    with SingleTickerProviderStateMixin {
  final Set<TextElement> _selectedElements = {};
  late AnimationController _glowController;

  Offset? _dragStart;
  Offset? _dragEnd;

  @override
  void initState() {
    super.initState();
    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _selectAll() {
    setState(() {
      final allElements = widget.recognizedText.blocks
          .expand((b) => b.lines)
          .expand((l) => l.elements)
          .toSet();
      if (_selectedElements.length == allElements.length) {
        _selectedElements.clear();
      } else {
        _selectedElements
          ..clear()
          ..addAll(allElements);
      }
    });
  }

  Future<ui.Image> _getImageInfo(File file) async {
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Text to Search"),
        actions: [
          TextButton(
            onPressed: _selectAll,
            child:
            const Text("Select All", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              final combined = _selectedElements.map((e) => e.text).join(' ');
              Navigator.pop(context, combined);
            },
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<ui.Image>(
            future: _getImageInfo(widget.imageFile),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final image = snapshot.data!;
              final double imageAspect = image.width / image.height;
              final double screenAspect =
                  constraints.maxWidth / constraints.maxHeight;

              double displayWidth, displayHeight;

              if (imageAspect > screenAspect) {
                displayWidth = constraints.maxWidth;
                displayHeight = displayWidth / imageAspect;
              } else {
                displayHeight = constraints.maxHeight;
                displayWidth = displayHeight * imageAspect;
              }

              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: displayWidth,
                    height: displayHeight,
                    child: Listener(
                      onPointerDown: (e) => _dragStart = e.localPosition,
                      onPointerMove: (e) => setState(() {
                        _dragEnd = e.localPosition;
                      }),
                      onPointerUp: (e) {
                        setState(() {
                          _dragEnd = e.localPosition;
                          _updateSelection(displayWidth, displayHeight, image);
                          _dragStart = _dragEnd = null;
                        });
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(widget.imageFile, fit: BoxFit.contain),
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _TextHighlightPainter(
                                  recognizedText: widget.recognizedText,
                                  selectedElements: _selectedElements,
                                  glow: _glowController.value,
                                  color: theme.colorScheme.primary,
                                  imageWidth: image.width.toDouble(),
                                  imageHeight: image.height.toDouble(),
                                  displayWidth: displayWidth,
                                  displayHeight: displayHeight,
                                  dragRect: _dragStart != null && _dragEnd != null
                                      ? Rect.fromPoints(_dragStart!, _dragEnd!)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateSelection(
      double displayWidth, double displayHeight, ui.Image image) {
    if (_dragStart == null || _dragEnd == null) return;
    final rect = Rect.fromPoints(_dragStart!, _dragEnd!);
    final scaleX = displayWidth / image.width;
    final scaleY = displayHeight / image.height;

    for (final block in widget.recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final elementRect = Rect.fromLTRB(
            element.boundingBox.left * scaleX,
            element.boundingBox.top * scaleY,
            element.boundingBox.right * scaleX,
            element.boundingBox.bottom * scaleY,
          );

          if (rect.overlaps(elementRect)) {
            _selectedElements.add(element);
          }
        }
      }
    }
  }
}

class _TextHighlightPainter extends CustomPainter {
  final RecognizedText recognizedText;
  final Set<TextElement> selectedElements;
  final double glow;
  final Color color;
  final double imageWidth;
  final double imageHeight;
  final double displayWidth;
  final double displayHeight;
  final Rect? dragRect;

  _TextHighlightPainter({
    required this.recognizedText,
    required this.selectedElements,
    required this.glow,
    required this.color,
    required this.imageWidth,
    required this.imageHeight,
    required this.displayWidth,
    required this.displayHeight,
    this.dragRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final scaleX = displayWidth / imageWidth;
    final scaleY = displayHeight / imageHeight;

    // Draw selection highlights
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final lineRect = line.boundingBox;
        final lineBox = Rect.fromLTRB(
          lineRect.left * scaleX,
          lineRect.top * scaleY,
          lineRect.right * scaleX,
          lineRect.bottom * scaleY,
        );

        // Draw faint line boundary to assist selection of full sentences
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = color.withOpacity(0.1);
        canvas.drawRect(lineBox, paint);

        for (final element in line.elements) {
          final rect = Rect.fromLTRB(
            element.boundingBox.left * scaleX,
            element.boundingBox.top * scaleY,
            element.boundingBox.right * scaleX,
            element.boundingBox.bottom * scaleY,
          );

          if (selectedElements.contains(element)) {
            paint
              ..style = PaintingStyle.fill
              ..color = color.withOpacity(0.35 + glow * 0.2);
            canvas.drawRect(rect, paint);

            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3
              ..color = color.withOpacity(0.9);
            canvas.drawRect(rect, paint);
          }
        }
      }
    }

    // Draw current drag rectangle
    if (dragRect != null) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withOpacity(0.5);
      canvas.drawRect(dragRect!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TextHighlightPainter oldDelegate) => true;
}
