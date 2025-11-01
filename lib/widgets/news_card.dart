import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';
import '../utils/constants.dart';
import '../views/home/news_detail_view.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final bool isJunior; // for junior mode colorful design
  const NewsCard({super.key, required this.article, this.isJunior = false});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLiked = false;
  bool isSaved = false;
  int likeCount = 0;
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    _loadArticleStatus();
  }

  Future<void> _loadArticleStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('articles').doc(widget.article.link);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      setState(() {
        likeCount = data['likes'] ?? 0;
        comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
      });
    }

    final userDoc =
    await _firestore.collection('users').doc(user.uid).get();
    final savedList =
    List<String>.from(userDoc.data()?['savedArticles'] ?? []);
    setState(() => isSaved = savedList.contains(widget.article.link ?? ''));
  }

  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final articleRef =
    _firestore.collection('articles').doc(widget.article.link);

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    await articleRef.set({
      'title': widget.article.title,
      'link': widget.article.link,
      'likes': likeCount,
    }, SetOptions(merge: true));
  }

  Future<void> _toggleSave() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final savedList = List<String>.from(doc.data()?['savedArticles'] ?? []);
    final articleUrl = widget.article.link ?? '';

    if (savedList.contains(articleUrl)) {
      savedList.remove(articleUrl);
      setState(() => isSaved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from Saved')),
      );
    } else {
      savedList.add(articleUrl);
      setState(() => isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved Successfully')),
      );
    }

    await docRef.update({'savedArticles': savedList});
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController commentController =
        TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Comments',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: comments.isEmpty
                        ? const Center(child: Text('No comments yet'))
                        : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.person,
                            color: Colors.grey),
                        title: Text(comments[i]['text']),
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send,
                            color: Constants.accentColor),
                        onPressed: () async {
                          if (commentController.text.trim().isNotEmpty) {
                            final newComment = {
                              'user': _auth.currentUser?.email ?? 'Anonymous',
                              'text': commentController.text.trim(),
                              'timestamp': FieldValue.serverTimestamp(),
                            };

                            setModalState(() {
                              comments.add(newComment);
                            });

                            await _firestore
                                .collection('articles')
                                .doc(widget.article.link)
                                .set({
                              'comments': comments,
                              'title': widget.article.title,
                              'link': widget.article.link,
                            }, SetOptions(merge: true));

                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => NewsDetailView(article: widget.article)),
      ),
      child: Card(
        color:
        widget.isJunior ? Colors.yellow[50] : Constants.backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.imageUrl != null &&
                widget.article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  widget.article.imageUrl!,
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
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title.isNotEmpty
                        ? widget.article.title
                        : 'No Title',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.article.description.isNotEmpty
                        ? widget.article.description
                        : 'No description available.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isLiked ? Colors.red : Constants.likeColor,
                            ),
                            onPressed: _toggleLike,
                          ),
                          Text(likeCount.toString()),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color:
                          isSaved ? Constants.accentColor : Colors.grey,
                        ),
                        onPressed: _toggleSave,
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.comment, color: Colors.grey),
                        onPressed: _showCommentsSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share,
                            color: Constants.accentColor),
                        onPressed: () {
                          if (widget.article.link != null &&
                              widget.article.link!.isNotEmpty) {
                            Share.share(widget.article.link!);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
