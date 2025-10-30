import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/news_model.dart';
import '../utils/constants.dart';
import '../views/home/news_detail_view.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailView(article: article),
          ),
        );
      },
      child: Card(
        color: Constants.backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  article.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description ?? 'No description available.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Constants.likeColor),
                        onPressed: () {
                          // TODO: Add "Save for Later" or Like functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Constants.accentColor),
                        onPressed: () {
                          if (article.link != null && article.link!.isNotEmpty) {
                            Share.share(article.link!);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.grey),
                        onPressed: () {
                          // Future: Add comment section here
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
