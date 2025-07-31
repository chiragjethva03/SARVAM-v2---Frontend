import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/app_drawer.dart';
import '../create_post_screen.dart';
import '../../services/post_service.dart'; // LikeService also inside here
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? userId;

  List<dynamic> posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    await _refreshPosts();
  }

  Future<void> _refreshPosts() async {
    try {
      setState(() => _isLoading = true);
      final data = await PostService.fetchPosts(userId: userId);
      setState(() {
        posts = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load posts")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToCreatePost() async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatePostScreen(userId: userId!)),
    );

    if (result == true) {
      _refreshPosts();
    }
  }

  Future<void> _toggleLike(int index) async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    final postId = posts[index]['_id'];
    try {
      final result = await LikeService.toggleLike(
        postId: postId,
        userId: userId!,
      );

      setState(() {
        posts[index] = {
          ...posts[index],
          'likesCount': result['likesCount'],
          'liked': result['liked'],
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to like post")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.04,
              ),
              child: Row(
                children: [
                  // Menu icon
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.menu, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Search Bar
                  Expanded(
                    child: CustomSearchBar(
                      controller: _searchController,
                      hintText: "Search posts",
                      onChanged: (value) {},
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  // Create Post Button
                  GestureDetector(
                    onTap: _navigateToCreatePost,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: ListView.separated(
                        itemCount: posts.length,
                        separatorBuilder: (context, index) => const Divider(
                          thickness: 1,
                          height: 30,
                          color: Colors.grey,
                        ),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final user = post['userId'];
                          final description = post['description'] ?? '';
                          final userName = user['fullName'] ?? 'Unknown';

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenWidth * 0.02,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Info
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2196F3,
                                        ).withOpacity(0.11),
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundImage:
                                            (user['profilePicture'] ?? '')
                                                .isNotEmpty
                                            ? NetworkImage(
                                                user['profilePicture'],
                                              )
                                            : null,
                                        child:
                                            (user['profilePicture'] ?? '')
                                                .isEmpty
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (post['location'] != null)
                                          Text(
                                            post['location'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Post Image
                                if (post['imageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: post['imageUrl'],
                                      width: double.infinity,
                                      height: 240,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                // Like and Share Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _toggleLike(index),
                                          child: Icon(
                                            post['liked'] == true
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: post['liked'] == true
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text("${post['likesCount'] ?? 0}"),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        Share.share(
                                          '${post['description'] ?? ''}\n${post['imageUrl'] ?? ''}',
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Description
                                RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 16),
                                    children: [
                                      TextSpan(
                                        text: "$userName :- ",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
