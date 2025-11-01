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

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
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
    const Placeholder(),
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
        title: const Text(
          "truthlens+",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 5,
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

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Constants.accentColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.search, 1),
            _buildNavItem(Icons.smart_toy_outlined, 2),
            _buildNavItem(Icons.person, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _bottomNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _bottomNavIndex = index);
        if (index == 0) {
          Provider.of<NewsController>(context, listen: false)
              .fetchNews(category: categories[_currentIndex]);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Constants.accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
              : [],
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            color: isSelected ? Constants.accentColor : Colors.grey[800],
            size: 28,
          ),
        ),
      ),
    );
  }
}
