class NewsArticle {
  final String title;
  final String description;
  final String? imageUrl;
  final String? link;
  final String category;
  final String? source;
  final String? pubDate;
  final String? content;

  NewsArticle({
    required this.title,
    required this.description,
    this.imageUrl,
    this.link,
    required this.category,
    this.source,
    this.pubDate,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {

    String? sourceName;
    if (json['source'] is Map) {
      sourceName = json['source']?['name']?.toString();
    } else if (json['source'] is String) {
      sourceName = json['source'];
    }


    String categoryValue = '';
    if (json['category'] is List && (json['category'] as List).isNotEmpty) {
      categoryValue = json['category'][0].toString();
    } else if (json['category'] is String) {
      categoryValue = json['category'];
    }

    return NewsArticle(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ??
          json['urlToImage']?.toString() ??
          '',
      link: json['link']?.toString() ?? json['url']?.toString(),
      category: categoryValue,
      source: sourceName ?? '',
      pubDate: json['pubDate']?.toString() ?? json['publishedAt']?.toString(),
      content: json['content']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link': link,
      'category': category,
      'source': source,
      'pubDate': pubDate,
      'content': content,
    };
  }
}
