                    // home screen of Application

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/constant/constants.dart';
import 'package:create_social/constant/utils.dart';
import 'package:create_social/customlibrary/readmore.dart';
import 'package:create_social/model/post.dart';
import 'package:create_social/model/user.dart' as m;
import 'package:create_social/pages/profile.dart';
import 'package:create_social/widgets/CustomHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../style/style.dart';
import '../widgets/VideoWidget/MultiVideoManager/flick_multi_manager.dart';
import '../widgets/VideoWidget/MultiVideoManager/flick_multi_player.dart';
import '../widgets/loading.dart';
import 'add_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, }) : super(key: key);

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  // variables
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _postStream;
  late FlickMultiManager flickMultiManager;
  late AutoScrollController autoScrollController;
  final List<Post> list = [];
  List<m.User> users = [];
  QuerySnapshot<Map<String, dynamic>>? snapshot;

  @override
  void initState() {
    super.initState();
    flickMultiManager = FlickMultiManager();
    autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, -10, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    _postStream = _db
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    flickMultiManager.dispose();
    super.dispose();
  }

// getting user list from firebase
  void getUserList() async {
    var result = await _db.collection("users").get();
    for (var element in result.docs) {
      users.add(m.User.fromJson(element.id, element.data()));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDataById(
      String id) async {
    await _db.collection("users").doc(id).get();
  }

  // UI of home Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          CustomHeader(
            leftChild: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddPost()));
              },
              icon: Image.asset(
                'images/add.png',
                color: Colors.black87,
              ),
            ),
            middleChild: const Text(
              'Home',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 0.5),
            ),
            rightChild: IconButton(
              onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) =>  ProfilePage(id: FirebaseAuth.instance.currentUser!.uid,))).then((value) async {
                 if(value != null && snapshot != null){
                   int scrollToIndex = snapshot!.docs.indexWhere((element) => element.id == value.id);
                   await autoScrollController.scrollToIndex(scrollToIndex,
                       duration: const Duration(milliseconds: 100),
                       preferPosition: AutoScrollPosition.begin);
                 }
               });
              },
              icon: Image.asset(
                'images/account.png',
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: StreamBuilder(
              stream: _postStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      snapshots) {
                if (snapshots.hasError) {
                  return Text(snapshots.error.toString());
                } else if (snapshots.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(child: CircularProgressIndicator()));
                }
                else{
                  snapshot = snapshots.data;
                }
                return snapshots.data != null
                    ? VisibilityDetector(
                        key: ObjectKey(flickMultiManager),
                        onVisibilityChanged: (visibility) {
                          if (visibility.visibleFraction == 0 && this.mounted) {
                            flickMultiManager.pause();
                          }
                        },
                        child: ListView.separated(
                          shrinkWrap: true,
                          controller: autoScrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshots.data!.docs.length,
                          itemBuilder: (context, index) {
                            Post post = Post.fromJson(
                                snapshots.data!.docs[index].id,
                                snapshots.data!.docs[index].data());

                            return AutoScrollTag(
                                key: ValueKey(index),
                                controller: autoScrollController,
                                index: index,
                                child: buildItem(post, snapshots.data!));
                          },
                          separatorBuilder: (context, index) {
                            return const Divider(
                              color: Colors.black,
                            );
                          },
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logos/ic_no_photo.png',
                              height: 150,
                              width: 150,
                              color: Colors.grey,
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(8, 20, 8, 4),
                              child: Text(
                                'No Post Available',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                "When you create a post, they'll show up here.",
                                style: TextStyle(
                                    color: Colors.grey,
                                    letterSpacing: 0.2,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    ));
  }

  //post view
  buildItem(Post post, QuerySnapshot<Map<String, dynamic>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                InkWell(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        ProfilePage(id: post.creator,))).then((value) async {
                      if(value != null){
                        int scrollToIndex = snapshot.docs.indexWhere((element) => element.id == value.id);
                        await autoScrollController.scrollToIndex(scrollToIndex,
                            duration: const Duration(milliseconds: 100),
                            preferPosition: AutoScrollPosition.begin);
                      }
                    });
                  },
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('images/no_photo.png'),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap:(){
                            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                                ProfilePage(id: post.creator,))).then((value) async {
                              if(value != null){
                                int scrollToIndex = snapshot.docs.indexWhere((element) => element.id == value.id);
                                await autoScrollController.scrollToIndex(scrollToIndex,
                                    duration: const Duration(milliseconds: 100),
                                    preferPosition: AutoScrollPosition.begin);
                              }
                            });;
                          },
                          child: CustomText(userId: post.creator),
                      ),
                      Text(
                        Utils.convertToAgo(context, post.createdAt),
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.black54),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: ReadMoreText(
                post.content,
                trimLines: 3,
                colorClickableText: Colors.blue,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'See More',
                delimiter: ' ',
                trimExpandedText: 'See Less',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                //showMoreText: widget.post.showMoreText,
                delimiterStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                moreStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                lessStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                linkStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
                onOpen: (link) async {
                  List<String> _temp =
                      post.content.replaceAll('\n', ' ').split(' ');
                  _temp.forEach((txtElement) {
                    if (txtElement
                        .replaceFirst('http://', '')
                        .replaceFirst('https://', '')
                        .contains(link.url
                            .replaceFirst('http://', '')
                            .replaceFirst('https://', ''))) {
                      _launchURL((txtElement.contains('http://') ||
                              txtElement.contains('https://'))
                          ? txtElement.replaceAll("\n", "")
                          : ('https://' + txtElement).replaceAll("\n", ""));
                    }
                  });
                },
              ),
            ),
          ],
          if (post.postFile.isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl: post.postFile,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => const Loading(),
                errorWidget: (context, url, error) => Image.asset(
                  'images/no_images.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  //making clickable URL in post
  Future<void> _launchURL(String link) async {

    if (await launchUrl(Uri.parse(link))) {
    } else {
      snackBar(context, 'Could not launch $link');
    }
  }
}

//
class CustomText extends StatelessWidget {
  final String userId;
  const CustomText({required this.userId});
  @override
  Widget build(context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
          if (snapshot.hasData) {
            try{
              return Text(snapshot.data!.data()!['name']);
            }catch(e){
              return const Text("User name");
            }
          } else {
            return const Text("User name");
          }
        }
    );
  }
}
