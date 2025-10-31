class NewsArticle {
  final String title;
  final String description;
  final String? imageUrl;
  final String? link;
  final String? category;
  final String? source;
  final String? pubDate;
  final String? content;

  NewsArticle({
    required this.title,
    required this.description,
    this.imageUrl,
    this.link,
    this.category,
    this.source,
    this.pubDate,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['urlToImage'],
      link: json['link'] ?? json['url'],
      category: (json['category'] != null && json['category'] is List)
          ? (json['category'] as List).isNotEmpty
          ? json['category'][0]
          : ''
          : (json['category'] ?? ''),
      source: json['source'] ?? '',
      pubDate: json['pubDate'] ?? json['publishedAt'],
      content: json['content'] ?? '',
    );
  }
}
