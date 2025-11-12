import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/news_model.dart';
import '../utils/constants.dart';
import '../views/home/news_detail_view.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final bool isJunior;
  const NewsCard({super.key, required this.article, this.isJunior = false});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterTts flutterTts = FlutterTts();

  bool isLiked = false;
  bool isSaved = false;
  bool isSpeaking = false;
  int likeCount = 0;
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    _loadArticleStatus();
    _setupTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  String _docIdFromLink(String? link) {
    if (link == null || link.isEmpty) {
      final fallback = widget.article.title;
      final bytes = utf8.encode(fallback);
      return base64Url.encode(bytes);
    }
    final bytes = utf8.encode(link);
    return base64Url.encode(bytes);
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.awaitSpeakCompletion(true);

    flutterTts.setStartHandler(() => setState(() => isSpeaking = true));
    flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    flutterTts.setErrorHandler((msg) {
      setState(() => isSpeaking = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('TTS error: $msg')));
    });
  }

  Future<void> _loadArticleStatus() async {
    try {
      final user = _auth.currentUser;
      final docId = _docIdFromLink(widget.article.link);
      final docRef = _firestore.collection('articles').doc(docId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data()!;
        setState(() {
          likeCount = (data['likes'] ?? 0) is int
              ? data['likes']
              : int.tryParse('${data['likes']}') ?? 0;
          comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        });
      } else {
        await docRef.set({
          'title': widget.article.title,
          'link': widget.article.link,
          'likes': 0,
        }, SetOptions(merge: true));
      }

      if (user != null) {
        final likedSnap = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('likedArticles')
            .doc(docId)
            .get();
        setState(() => isLiked = likedSnap.exists);

        final savedSnap = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('savedArticles')
            .doc(docId)
            .get();
        setState(() => isSaved = savedSnap.exists);
      }
    } catch (e) {
      debugPrint('Error loading article status: $e');
    }
  }

  // ✅ UPDATED to sync arrays in user doc (for ProfileView)
  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like articles')),
      );
      return;
    }

    final docId = _docIdFromLink(widget.article.link);
    final articleRef = _firestore.collection('articles').doc(docId);
    final userRef = _firestore.collection('users').doc(user.uid);
    final userLikeRef = userRef.collection('likedArticles').doc(docId);

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      if (likeCount < 0) likeCount = 0;
    });

    try {
      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(articleRef);
        int currentLikes =
        snapshot.exists ? (snapshot.data()!['likes'] ?? 0) : 0;
        tx.set(
          articleRef,
          {
            'title': widget.article.title,
            'link': widget.article.link,
            'likes': isLiked
                ? currentLikes + 1
                : (currentLikes - 1).clamp(0, 999999),
          },
          SetOptions(merge: true),
        );

        if (isLiked) {
          tx.set(
              userLikeRef,
              {'liked': true, 'timestamp': FieldValue.serverTimestamp()});
          tx.update(userRef, {
            'likedArticles': FieldValue.arrayUnion([docId])
          });
        } else {
          tx.delete(userLikeRef);
          tx.update(userRef, {
            'likedArticles': FieldValue.arrayRemove([docId])
          });
        }
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  // ✅ UPDATED to sync arrays in user doc (for ProfileView)
  Future<void> _toggleSave() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save articles')),
      );
      return;
    }

    final docId = _docIdFromLink(widget.article.link);
    final userRef = _firestore.collection('users').doc(user.uid);
    final userSavedRef = userRef.collection('savedArticles').doc(docId);

    try {
      if (isSaved) {
        await userSavedRef.delete();
        await userRef.update({
          'savedArticles': FieldValue.arrayRemove([docId])
        });
        setState(() => isSaved = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Removed from Saved')));
      } else {
        await userSavedRef.set({
          'title': widget.article.title,
          'description': widget.article.description,
          'imageUrl': widget.article.imageUrl,
          'link': widget.article.link,
          'source': widget.article.source,
          'pubDate': widget.article.pubDate,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await userRef.update({
          'savedArticles': FieldValue.arrayUnion([docId])
        });
        setState(() => isSaved = true);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Saved Successfully')));
      }
    } catch (e) {
      debugPrint('Error toggling save: $e');
    }
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final commentController = TextEditingController();
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: comments.isEmpty
                    ? const Center(child: Text('No comments yet'))
                    : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (_, i) => ListTile(
                    leading:
                    const Icon(Icons.person, color: Colors.grey),
                    title: Text(comments[i]['text']),
                  ),
                ),
              ),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Constants.accentColor),
                  onPressed: () async {
                    if (commentController.text.trim().isNotEmpty) {
                      final newComment = {
                        'user': _auth.currentUser?.email ?? 'Anonymous',
                        'text': commentController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      setModalState(() => comments.add(newComment));

                      final docId = _docIdFromLink(widget.article.link);
                      await _firestore
                          .collection('articles')
                          .doc(docId)
                          .set({
                        'comments': comments,
                        'title': widget.article.title,
                        'link': widget.article.link,
                      }, SetOptions(merge: true));
                      commentController.clear();
                    }
                  },
                ),
              ]),
            ]),
          );
        });
      },
    );
  }

  Future<void> _toggleSpeech() async {
    try {
      if (isSpeaking) {
        await flutterTts.stop();
        setState(() => isSpeaking = false);
      } else {
        final text = '${widget.article.title}. ${widget.article.description}';
        setState(() => isSpeaking = true);
        await flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('TTS toggle error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pastelColors = [
      Colors.pink[50],
      Colors.blue[50],
      Colors.green[50],
      Colors.orange[50],
      Colors.purple[50],
      Colors.teal[50],
    ];

    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.themeIndex == 2;

    final Color cardColor = widget.isJunior
        ? (pastelColors[
    (widget.article.title.hashCode) % pastelColors.length] ??
        Colors.yellow[50]!)
        : themeController.themeIndex == 0
        ? Constants.defaultBackground
        : themeController.themeIndex == 1
        ? Constants.lightBackground
        : Constants.darkBackground;

    final textColor =
    widget.isJunior ? Colors.black : (isDark ? Colors.white : Colors.black87);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => NewsDetailView(article: widget.article)),
      ),
      child: Card(
        color: cardColor,
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
                    const BorderRadius.vertical(top: Radius.circular(15))),
                child: const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.article.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    widget.article.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(children: [
                        IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isLiked ? Colors.red : Constants.likeColor,
                            ),
                            onPressed: _toggleLike),
                        Text('$likeCount', style: TextStyle(color: textColor)),
                      ]),
                      IconButton(
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isSaved
                                ? Constants.accentColor
                                : Colors.grey,
                          ),
                          onPressed: _toggleSave),
                      IconButton(
                          icon: const Icon(Icons.comment, color: Colors.grey),
                          onPressed: _showCommentsSheet),
                      IconButton(
                          icon: const Icon(Icons.share,
                              color: Constants.accentColor),
                          onPressed: () {
                            if (widget.article.link != null) {
                              Share.share(widget.article.link!);
                            }
                          }),
                      IconButton(
                          icon: Icon(
                            isSpeaking
                                ? Icons.stop_circle_outlined
                                : Icons.volume_up,
                            color: Constants.accentColor,
                          ),
                          onPressed: _toggleSpeech),
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
