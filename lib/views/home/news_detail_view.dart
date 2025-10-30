import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_model.dart'; // import your model
import '../../utils/constants.dart';

class NewsDetailView extends StatelessWidget {
  final NewsArticle article; // <-- change NewsModel to NewsArticle
  const NewsDetailView({super.key, required this.article});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: const Text('News Details', style: TextStyle(color: Colors.white)),
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
                child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            Text(
              article.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  article.source ?? 'Unknown Source',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  article.pubDate != null
                      ? DateFormat('dd MMM yyyy').format(DateTime.parse(article.pubDate!))
                      : '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1.2),
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
            ElevatedButton.icon(
              onPressed: () {
                if (article.link != null) _launchURL(article.link!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.accentColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              label: const Text('Read Full Article', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
