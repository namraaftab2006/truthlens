class NewsArticle {
  final String title;
  final String description;
  final String? imageUrl;
  final String? link;
  final String? category;
  final String? source;   // new
  final String? pubDate;  // new
  final String? content;  // new

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
      imageUrl: json['image_url'],
      link: json['link'],
      category: (json['category'] != null && json['category'] is List)
          ? (json['category'] as List).isNotEmpty
          ? json['category'][0]
          : ''
          : '',
      source: json['source'] ?? '',                       // new
      pubDate: json['pubDate'] ?? json['publishedAt'],    // new: check your API key
      content: json['content'] ?? '',                     // new
    );
  }
}
