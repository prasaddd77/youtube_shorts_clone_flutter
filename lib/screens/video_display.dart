import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shorts_clone/screens/video_playing.dart';

import '../model/model.dart';

class VideoDisplayScreen extends StatefulWidget {
  const VideoDisplayScreen({super.key});

  @override
  State<VideoDisplayScreen> createState() => _VideoDisplayScreenState();
}

class _VideoDisplayScreenState extends State<VideoDisplayScreen> {
  final _baseUrl = "https://internship-service.onrender.com/videos";
  int currentPage = 0;
  int limit = 10;
  int totalPageCount = 9;
  List<Post> _videos = [];

  RefreshController refreshController = RefreshController();

  Future<bool> getVideoData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 0;
    } else {
      if (currentPage > totalPageCount) {
        refreshController.loadNoData();
        return false;
      }
    }

    final Uri uri = Uri.parse("$_baseUrl?page=$currentPage&limit=$limit");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final result = welcomeFromJson(response.body);

      if (isRefresh) {
        _videos = result.data.posts;
      } else {
        _videos.addAll(result.data.posts);
      }

      currentPage++;

      setState(() {});

      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    refreshController = RefreshController(initialRefresh: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SmartRefresher(
          controller: refreshController,
          //enablePullDown: true,
          enablePullUp: true,
          onRefresh: () async {
            final result = await getVideoData(isRefresh: true);
            if (result) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          },
          onLoading: () async {
            final result = await getVideoData();
            if (result) {
              refreshController.loadComplete();
            } else {
              refreshController.loadFailed();
            }
          },
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // crossAxisSpacing: 1,
                mainAxisSpacing: 15,
                childAspectRatio: 0.7),
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              final video = _videos[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoPlayingScreen(),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          video.submission.thumbnail,
                          //width: 250,
                          //height: 150,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // adjust the values as per your requirements
                    left: 16,
                    right: 16,
                    child: Text(
                      video.submission.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
