import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/search_bar.dart';
import '../create_post_screen.dart';
import '../../services/post_service.dart';
import 'package:share_plus/share_plus.dart'; // for sharing posts

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
    _loadUserId();
    _refreshPosts();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId");
    });
  }

  Future<void> _refreshPosts() async {
    try {
      setState(() => _isLoading = true);
      final data = await PostService.fetchPosts();
      setState(() {
        posts = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load posts")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToCreatePost() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(userId: userId!),
      ),
    );

    if (result == true) {
      _refreshPosts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.04,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: "Search posts",
                    onChanged: (value) {},
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                GestureDetector(
                  onTap: _navigateToCreatePost,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // Posts
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final user = post['userId']; // populated user object

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.02,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row: profile picture + (name + location)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          (user['profilePicture'] ?? '')
                                                  .isNotEmpty
                                              ? NetworkImage(
                                                  user['profilePicture'])
                                              : null,
                                      child: (user['profilePicture'] ?? '')
                                              .isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                      radius: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['fullName'] ?? "Unknown",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (post['location'] != null)
                                          Text(
                                            post['location'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Post image
                                if (post['imageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      post['imageUrl'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Like & Share row (old style)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite_border),
                                        const SizedBox(width: 4),
                                        Text('${post['likes'] ?? 0}'),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        Share.share(
                                            '${post['description'] ?? ''}\n${post['imageUrl'] ?? ''}');
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Description
                                Text(
                                  post['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16, // Bigger text
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
