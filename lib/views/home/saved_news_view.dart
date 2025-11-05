import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedNewsView extends StatelessWidget {
  const SavedNewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved News'),
          backgroundColor: const Color(0xFF246272),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('savedArticles')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedNews = snapshot.data!.docs;

          if (savedNews.isEmpty) {
            return const Center(child: Text('No saved news yet.'));
          }

          return ListView.builder(
            itemCount: savedNews.length,
            itemBuilder: (context, index) {
              final article = savedNews[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: article['imageUrl'] != null
                      ? Image.network(article['imageUrl'],
                      width: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(article['title'] ?? 'Untitled'),
                  subtitle: Text(article['source'] ?? ''),
                  onTap: () {
                    // open detailed view later
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
