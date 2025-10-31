import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/news_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/news_card.dart';
import 'shimmer_loader.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch top headlines initially
    final controller = Provider.of<NewsController>(context, listen: false);
    controller.fetchTopHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NewsController>(context);

    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: const Text('Search News', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(controller),
              decoration: InputDecoration(
                hintText: 'Search any topic...',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          controller.fetchTopHeadlines();
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Constants.accentColor),
                      onPressed: () => _performSearch(controller),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Constants.accentColor),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const ShimmerLoader()
                : controller.newsList.isEmpty
                ? const Center(child: Text('No news found. Try searching something else!'))
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
}
