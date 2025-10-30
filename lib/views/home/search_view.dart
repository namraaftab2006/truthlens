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
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NewsController>(context);

    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: const Text('Search News', style: TextStyle(color: Colors.blueGrey)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                setState(() => _searchQuery = value.trim());
                if (_searchQuery.isNotEmpty) {
                  controller.fetchNews(query: _searchQuery);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search any topic...',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Constants.accentColor),
                  onPressed: () {
                    setState(() => _searchQuery = _searchController.text.trim());
                    if (_searchQuery.isNotEmpty) {
                      controller.fetchNews(query: _searchQuery);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Constants.accentColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const ShimmerLoader()
                : controller.newsList.isEmpty
                ? const Center(child: Text('search here'))
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
}
