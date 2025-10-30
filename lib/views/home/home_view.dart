import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/news_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/news_card.dart';
import 'shimmer_loader.dart';
import 'search_view.dart';
import 'ai_chat_view.dart';
import 'profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final List<String> categories = ['forYou', 'sports', 'entertainment', 'politics', 'junior'];
  final List<String> categoryNames = ['For You', 'Sports', 'Entertainment', 'Politics', 'Junior Mode'];

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<NewsController>(context, listen: false);
    controller.fetchNews(category: categories[_currentIndex]);
  }

  void _onCategorySelected(int index) {
    setState(() => _currentIndex = index);
    final controller = Provider.of<NewsController>(context, listen: false);
    controller.fetchNews(category: categories[index]);
  }

  int _bottomNavIndex = 0;

  final List<Widget> _bottomNavPages = [
    const Placeholder(), // home (we’ll replace this dynamically)
    const SearchView(),
    const AiChatView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NewsController>(context);

    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: Text(
          "truthlens+",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _bottomNavIndex == 0
          ? Column(
        children: [
          // Category tabs
          Container(
            height: 50,
            color: Constants.backgroundColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () => _onCategorySelected(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Constants.accentColor : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Constants.accentColor),
                    ),
                    child: Text(
                      categoryNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Constants.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // News list
          Expanded(
            child: controller.isLoading
                ? const ShimmerLoader()
                : RefreshIndicator(
              onRefresh: () async {
                await controller.fetchNews(category: categories[_currentIndex]);
              },
              child: ListView.builder(
                itemCount: controller.newsList.length,
                itemBuilder: (context, index) {
                  final article = controller.newsList[index];
                  return NewsCard(article: article);
                },
              ),
            ),
          ),
        ],
      )
          : _bottomNavPages[_bottomNavIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        backgroundColor: Constants.accentColor,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.brown,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 0) {
            Provider.of<NewsController>(context, listen: false)
                .fetchNews(category: categories[_currentIndex]);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
