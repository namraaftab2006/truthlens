import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/news_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/news_card.dart';
import 'shimmer_loader.dart';
import 'search_view.dart';
import 'ai_chat_view.dart';
import 'profile_view.dart';

/// 🧒 Simple Junior Mode View placeholder
class JuniorModeView extends StatelessWidget {
  const JuniorModeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NewsController>(context);

    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: const Text('Junior Mode', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: controller.isLoading
          ? const ShimmerLoader()
          : RefreshIndicator(
        onRefresh: () async {
          await controller.fetchNews(category: 'junior');
        },
        child: ListView.builder(
          itemCount: controller.newsList.length,
          itemBuilder: (context, index) {
            final article = controller.newsList[index];
            return NewsCard(article: article, isJunior: true);
          },
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _bottomNavIndex = 0;

  final List<String> categories = [
    'forYou',
    'sports',
    'entertainment',
    'politics',
  ];

  final List<Map<String, dynamic>> categoryData = [
    {'name': 'For You', 'icon': Icons.star},
    {'name': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Politics', 'icon': Icons.account_balance},
  ];

  // ✅ 5 pages for 5 nav items
  final List<Widget> _bottomNavPages = const [
    Placeholder(),
    SearchView(),
    AiChatView(),
    ProfileView(),
    JuniorModeView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsController>(context, listen: false)
          .fetchNews(category: categories[_currentIndex]);
    });
  }

  void _onCategorySelected(int index) {
    setState(() => _currentIndex = index);
    Provider.of<NewsController>(context, listen: false)
        .fetchNews(category: categories[index]);
  }

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
        elevation: 5,
      ),
      body: _bottomNavIndex == 0
          ? Column(
        children: [
          _buildCategoryTabs(),
          const SizedBox(height: 8),
          Expanded(
            child: controller.isLoading
                ? const ShimmerLoader()
                : RefreshIndicator(
              onRefresh: () async {
                await controller.fetchNews(
                    category: categories[_currentIndex]);
              },
              child: ListView.builder(
                itemCount: controller.newsList.length,
                itemBuilder: (context, index) {
                  final article = controller.newsList[index];
                  final isJuniorMode =
                      controller.currentCategory == 'junior';
                  return NewsCard(
                      article: article, isJunior: isJuniorMode);
                },
              ),
            ),
          ),
        ],
      )
          : _bottomNavPages[_bottomNavIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// 🌈 Visually enhanced category bar
  Widget _buildCategoryTabs() {
    return Container(
      height: 70,
      color: Constants.backgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryData.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final data = categoryData[index];

          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    Constants.accentColor,
                    Constants.accentColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : const LinearGradient(colors: [Colors.white, Colors.white]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Constants.accentColor),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Constants.accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    data['icon'],
                    color: isSelected ? Colors.white : Constants.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Constants.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🧭 Bottom navigation bar (with Junior Mode)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Constants.accentColor,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.search, 1),
          _buildNavItem(Icons.child_care, 4), // 🧒 Junior Mode
          _buildNavItem(Icons.smart_toy_outlined, 2),
          _buildNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  /// 📱 Helper for bottom nav buttons
  Widget _buildNavItem(IconData icon, int index, {String? label}) {
    final isSelected = _bottomNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _bottomNavIndex = index);

        if (index == 0) {
          Provider.of<NewsController>(context, listen: false)
              .fetchNews(category: categories[_currentIndex]);
        } else if (index == 4) {
          Provider.of<NewsController>(context, listen: false)
              .fetchNews(category: "junior");
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Constants.accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            color: isSelected ? Constants.accentColor : Colors.grey[800],
            size: 26,
          ),
        ),
      ),
    );
  }
}
