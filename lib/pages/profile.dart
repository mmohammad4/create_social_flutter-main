//              App Profile UI

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/pages/home.dart';
import 'package:create_social/pages/authentication.dart';
import 'package:create_social/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant/utils.dart';
import '../model/post.dart';
import '../model/user.dart' as m;
import '../widgets/CustomHeader.dart';
import 'dart:math' as math;
class ProfilePage extends StatefulWidget {
  final String id;
  const ProfilePage({Key? key, required this.id}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  m.User? user;
  List<Post> posts=[];
  @override
  void initState() {
    super.initState();
    getList2();
    _db.collection("users").doc(widget.id).get().then((value){
      if( value.data() != null){
        setState(() {
          user = m.User.fromJson(value.id, value.data()!);
        });
      }
    });
  }

  // getting data from firebase
  void getList2() async {
    var result = await _db.collection("posts").where("creator",isEqualTo: widget.id).get();
    setState(() {
      posts.clear();
    });
    for (var element in result.docs) {
      setState(() {
        posts.add(Post.fromJson(element.id, element.data()));
      });
    }
  }

  //UI for profile screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: user == null
            ? const Loading()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.4,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.4,
                            width: double.maxFinite,
                            child: Image.asset(
                              'images/no_account.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          CustomHeader(
                            leftChild: IconButton(
                              color: Colors.black,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.asset('images/back.png',
                                color: Colors.black,
                              ),
                            ),
                            middleChild: Container(),
                            rightChild: FirebaseAuth.instance.currentUser?.uid == widget.id ? IconButton(
                              onPressed: () async {                   // sign out function
                                Utils.showTwoButtonAlertDialog(
                                    context: context,
                                    alertTitle: 'Sign Out',
                                    alertMsg: 'Are you sure to Sign out?',
                                    positiveText: 'OK',
                                    negativeText: 'Cancel',
                                    yesTap: () async {
                                      Utils.showLoader();
                                      await FirebaseAuth.instance.signOut().then((value) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context)=> const Authentication()),
                                                (route) => false);
                                      });
                                      Utils.hideLoader();
                                    }
                                );
                              },
                              icon: const Icon(
                                Icons.logout_outlined,
                                color: Colors.black,
                                size: 40,
                              )
                              /*Image.asset('images/log-out.png',
                                color: Colors.blue,
                              ),*/
                            ): const SizedBox(width: 30,),
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(height: 30,),
                    const Padding(
                      padding:  EdgeInsets.only(left: 15.0),
                      child: Text(
                        "Basic Info",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    ListTile(
                      title:  Text(
                        user!.name,
                        style:const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900
                        ),
                      ),
                      subtitle:  Text(
                        user!.bio,
                        style:const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15,),
                    if(posts.isNotEmpty)...[

                      const Padding(
                        padding:  EdgeInsets.only(left: 15.0),
                        child: Text(
                          "Posts",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900
                          ),
                        ),
                      ),
                      Flexible(child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                            childAspectRatio:1/1.15,
                          ),
                          shrinkWrap: true,
                          itemCount: posts.length,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5,horizontal: 15),
                          itemBuilder: (BuildContext ctx, int index) {
                            return InkWell(
                              onTap: (){
                                Navigator.pop(
                                  context,posts[index]);
                              },
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: posts[index].postFile.isNotEmpty ?
                                  Utils.loadCachedNetworkImage(
                                      (posts[index].postFile),
                                      provider: 'images/no_images.png'):
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 7,horizontal: 12),
                                    color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      posts[index].content,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 6,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),),
                                  )
                              ),
                            );
                          }),)
                    ]
                  ],
                ),
              ),
      ),
    );
  }

}
