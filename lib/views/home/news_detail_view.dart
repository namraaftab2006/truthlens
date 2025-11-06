import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../models/news_model.dart';
import '../../utils/constants.dart';
import '../../controllers/theme_controller.dart';

class NewsDetailView extends StatefulWidget {
  final NewsArticle article;
  const NewsDetailView({super.key, required this.article});

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  double _speechRate = 0.5;

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _speak() async {
    final text =
        "${widget.article.title}. ${widget.article.description ?? ''} ${widget.article.content ?? ''}";
    if (text.trim().isEmpty) return;

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.speak(text);
    setState(() => isPlaying = true);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final theme = Theme.of(context);
    final article = widget.article;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ theme-based
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'News Details',
          style: theme.appBarTheme.titleTextStyle ??
              const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              if (article.link != null) Share.share(article.link!);
            },
          ),
          // 🌗 Add theme toggle in AppBar
          IconButton(
            icon: Icon(themeController.themeIcon,
                color: theme.appBarTheme.foregroundColor),
            onPressed: themeController.toggleTheme,
            tooltip: 'Change Theme',
          ),
        ],
      ),

      // 📄 Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(article.imageUrl!, fit: BoxFit.cover),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.image_not_supported,
                    size: 60, color: theme.iconTheme.color),
              ),

            const SizedBox(height: 20),

            // 📰 Title
            Text(
              article.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ) ??
                  const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🕒 Source + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  article.source ?? 'Unknown Source',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  article.pubDate != null
                      ? DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(article.pubDate!))
                      : '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),

            const Divider(height: 30, thickness: 1.2),

            // 📖 Description
            Text(
              article.description,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            // 📘 Content (if available)
            if (article.content != null && article.content!.isNotEmpty)
              Text(
                article.content!,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
              ),

            const SizedBox(height: 30),

            // 🔊 Listen / Stop
            Center(
              child: ElevatedButton.icon(
                onPressed: isPlaying ? _stop : _speak,
                icon: Icon(isPlaying ? Icons.stop : Icons.volume_up,
                    color: Colors.white),
                label: Text(
                  isPlaying ? 'Stop Listening' : 'Listen to this News',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🎚️ Speed Control
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Adjust Reading Speed:",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: _speechRate,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  label: "${_speechRate.toStringAsFixed(1)}x",
                  activeColor: Constants.accentColor,
                  onChanged: (value) async {
                    setState(() => _speechRate = value);
                    await flutterTts.setSpeechRate(_speechRate);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🌐 Open Full Article
            ElevatedButton.icon(
              onPressed: () {
                if (article.link != null) _launchURL(article.link!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.accentColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              label: const Text('Read Full Article',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
