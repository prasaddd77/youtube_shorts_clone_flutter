import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shorts_clone/model/model.dart';
import 'package:shorts_clone/widgets/video_play_item.dart';

class VideoPlayingScreen extends StatefulWidget {
  const VideoPlayingScreen({super.key});

  @override
  State<VideoPlayingScreen> createState() => _VideoPlayingScreenState();
}

class _VideoPlayingScreenState extends State<VideoPlayingScreen> {
  final _baseUrl = "https://internship-service.onrender.com/videos";
  int currentPage = 0;
  int limit = 10;
  int totalPageCount = 9;
  List<Post> _videos = [];

  RefreshController refreshController = RefreshController();

  PageController pageController = PageController();

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
    pageController = PageController(initialPage: 0, viewportFraction: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SmartRefresher(
        controller: refreshController,
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
        child: PageView.builder(
          controller: pageController,
          scrollDirection: Axis.vertical,
          itemBuilder: (_, index) {
            final video = _videos[index];
            return Stack(
              children: [
                VideoPlayItem(videoUrl: video.submission.mediaUrl),
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage:
                                            NetworkImage(video.creator.pic),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "@${video.creator.handle}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          minimumSize: const Size(36, 25),
                                        ),
                                        child: const Text(
                                          "Subscribe",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    video.submission.description,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 65,
                            margin: EdgeInsets.only(top: size.height / 5),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.thumb_up,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  video.reaction.count.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.thumb_down,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                const Text(
                                  "Dislike",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.comment,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  video.comment.count.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: () {},
                                  child: const Icon(
                                    Icons.share,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                const Text(
                                  "Share",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          },
          itemCount: _videos.length,
          onPageChanged: (page) {
            setState(() {
              page = currentPage;
              getVideoData();
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    refreshController.dispose();
    pageController.dispose();
    super.dispose();
  }
}
