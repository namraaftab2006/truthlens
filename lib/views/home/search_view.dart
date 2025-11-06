import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final themeController = Provider.of<ThemeController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(controller),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Search any topic...',
                hintStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor, // 🆕 adapts to theme
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close, color: theme.iconTheme.color),
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
                  borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: theme.dividerColor.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
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
}
