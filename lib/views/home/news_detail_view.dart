import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/news_model.dart';
import '../../utils/constants.dart';

class NewsDetailView extends StatefulWidget {
  final NewsArticle article;
  const NewsDetailView({super.key, required this.article});

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  // 🆕 Added: speech rate state
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
    await flutterTts.setSpeechRate(_speechRate); // 🆕 dynamic rate
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
    final article = widget.article;
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title:
        const Text('News Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              if (article.link != null) Share.share(article.link!);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image Section
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey),
              ),

            const SizedBox(height: 20),

            // 📰 Title
            Text(
              article.title,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🕒 Source & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  article.source ?? 'Unknown Source',
                  style:
                  const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  article.pubDate != null
                      ? DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(article.pubDate!))
                      : '',
                  style:
                  const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),

            const Divider(height: 30, thickness: 1.2),

            // 📖 Description + Content
            Text(
              article.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            if (article.content != null && article.content!.isNotEmpty)
              Text(
                article.content!,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),

            const SizedBox(height: 30),

            // 🔊 Listen / Stop Button
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

            // 🆕 Speech Speed Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Adjust Reading Speed:",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
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

            // 🌐 Open Full Article Button
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
