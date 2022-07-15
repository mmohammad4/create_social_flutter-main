import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:create_social/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/constants.dart';
import '../constant/utils.dart';
import '../model/user.dart';
import '../widgets/CustomHeader.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  // variables for UI
  TextEditingController textController = TextEditingController();
  XFile? imageFile;
  bool formValiadtor = false;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHeader(
                    leftChild: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        'images/back.png',
                        color: Colors.black87,
                      ),
                    ),
                    middleChild: const Text(
                      'Add Post',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: 0.5),
                    ),
                    rightChild:const SizedBox(width: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 75,
                  ),
                  Center(
                    child: InkWell(
                      splashColor: Colors.black,
                      onTap: () {
                        showBottomSheetForImageSelectionType(context); //bottom sheet for image selection
                      },
                      child: Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey.withOpacity(0.6),
                        ),
                        child: imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.file(
                                  File(imageFile!.path),
                                  fit: BoxFit.cover,
                                ))
                            : const Icon(
                                Icons.add,
                                size: 45,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 75,
                  ),
                  Padding(                                                    // textfield for text post
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextField(
                      controller: textController,
                      minLines: 8,
                      maxLines: 100,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      maxLength: 8000,
                      cursorColor: Colors.black,
                      cursorHeight: 25,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.all(20),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          borderSide: BorderSide(width: 1.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintText: "Express your thoughts here…",
                        hintStyle: TextStyle(
                          fontSize: 25,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          RawMaterialButton(                // button for add post
            elevation: 5.0,
            onPressed: () async {
              checkButtonValidation();
              Utils.showLoader();
                String imageUrl = imageFile != null ?  await uploadImage(imageFile!.path) : '';
                formValiadtor ? addPostToFireStore(imageUrl) :
                Utils.showToastMessage('Please add Text or Image to post.');
                Utils.hideLoader();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              width: 150,
              height: 50,
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Add Post",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    ));
  }

  //bottomsheet for camera and image
  showBottomSheetForImageSelectionType(context) async {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding:
                const EdgeInsets.only(top: 10, right: 15, left: 15, bottom: 10),
            width: double.maxFinite,
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: const Text(
                    'Please Select',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Divider(
                    thickness: 1.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: const Text(
                      'Take Photo',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    imagePicker('Camera');
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      'Photo',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();

                    imagePicker('Gallery');
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                /*InkWell(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      'Create Video',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();

                    createVideo('Gallery');
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      'Video',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();

                    pickVideo('Gallery');
                  },
                ),
                const SizedBox(
                  height: 5,
                ),*/
              ],
            ),
          );
        });
  }

  //image picker from gallery and camera
  imagePicker(String type) async {
    try {
      XFile? file;
      ImagePicker picker = ImagePicker();
      type == 'Camera'
          ? file = await picker.pickImage(source: ImageSource.camera)
          : file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        final dir2 = await path_provider.getTemporaryDirectory(); //compresing image before uploading
        final targetPath = dir2.absolute.path + "/" +"temp$file" + Utils.generateRandomString1(16) + ".jpg";
        File? compressedFile =
            await Utils.compressImages(file.path, targetPath);
        setState(() {
          imageFile = XFile(compressedFile!.path);
          cropImage();
        });
      } else {
      }
    } catch (e) {
      PermissionStatus photosPermission = await Permission.photos.status;
      PermissionStatus cameraPermission = await Permission.camera.status;

      if (photosPermission != PermissionStatus.granted) {
        Utils.showTwoButtonAlertDialog(
          context: context,
          alertTitle: 'Allow access to your photos',
          alertMsg: 'Allow Benang to use your photos to set a profile picture.',
          positiveText: 'Open Settings',
          negativeText: 'Not Now',
          yesTap: () async {
            await openAppSettings();
          },
        );
      }
      if (cameraPermission != PermissionStatus.granted) {
        Utils.showTwoButtonAlertDialog(
          context: context,
          alertTitle: 'Allow access to your camera',
          alertMsg: 'Allow Benang to use your camera to set a profile picture.',
          positiveText: 'Open Settings',
          negativeText: 'Not Now',
          yesTap: () async {
            await openAppSettings();
          },
        );
      }
    }
  }

  //validation for post
  checkButtonValidation() {
    if (textController.text.isNotEmpty || imageFile != null) {
      setState(() {
        formValiadtor = true;
      });
      // print('invalid');
    } else {
      setState(() {
        formValiadtor = false;
      });
      // print('validate');
    }
  }

  // upload image to firebase and return image URL
  Future<String> uploadImage(String imagePath) async {
    bool conn = await Utils.checkInternetConnection();
    if(conn){
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString(); //timestamp for post
      String uploadPath = "/posts/$timeStamp";
      uploadPath += getFileExtension(imagePath);
      TaskSnapshot taskSnapshot = await _firebaseStorage.ref(uploadPath).putFile(File(imagePath));
      if (taskSnapshot.state == TaskState.success) {
        return await taskSnapshot.ref.getDownloadURL();
      } else {
        debugPrint(taskSnapshot.toString());
        debugPrint(taskSnapshot.state.name);
        return '';
      }
    }else{
      Utils.showToastMessage('Check Internet Connection');
      return '';
    }

  }

  // file extension for images
  String getFileExtension(String fileName) {
    try {
      return "." + fileName.split('.').last;
    } catch(e){
      return 'null';
    }
  }

  // crop to square image
  cropImage() async {
    if(imageFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        aspectRatioPresets: [
        CropAspectRatioPreset.square,
          ],
      );
      if(croppedFile != null && imageFile != null){
        setState((){
          imageFile = XFile(croppedFile.path);
        });
      }
    }
  }

  // adding new collection to firestore
  addPostToFireStore(String imageUrl) async {
      DocumentReference<Map<String, dynamic>> data =
      await FirebaseFirestore.instance.collection('posts').add({
        'content': textController.text.toString(),
        'createdAt': Timestamp.now(),
        'postFile': imageUrl,
        'creator': FirebaseAuth.instance.currentUser?.uid,
        'postType': imageUrl == '' ? Constants.textPost : Constants.imagePost,
      });
      if(this.mounted){
        Utils.showToastMessage('Post Added SuccessFully.');
        Navigator.pop(context);                                     // back to home screen
      }
  }
}
