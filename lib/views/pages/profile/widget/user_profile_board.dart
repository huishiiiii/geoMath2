import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/gender_enum.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/asset_helper.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/user_model.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileBoard extends StatefulWidget {
  final UserModel user;
  const UserProfileBoard({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileBoard> createState() => _UserProfileBoardState();
}

class _UserProfileBoardState extends State<UserProfileBoard> {
  FirebaseService firebaseService = FirebaseService();
  File? selectedIMage;
  UploadTask? uploadTask;

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        backgroundColor: Theme.of(context).colorScheme.surface,
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 16,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 30,
                            ),
                            Text(TextConstant.gallery)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 30,
                            ),
                            Text(TextConstant.camera)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

//Gallery
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      // _image = File(returnImage.path).readAsBytesSync();
    });
    String imageUrl = await uploadImageToFirebase(selectedIMage!);
    updateProfileImage(imageUrl);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(); //close the model sheet
  }

//Camera
  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      // _image = File(returnImage.path).readAsBytesSync();
    });
    String imageUrl = await uploadImageToFirebase(selectedIMage!);
    updateProfileImage(imageUrl);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  Future<String> uploadImageToFirebase(File _imageFile) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_imageFile.path.split('/').last}';

      // Create a Reference to the location in Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/${user?.uid}/$fileName');

      // Upload the file to Firebase Storage
      setState(() {
        uploadTask = storageReference.putFile(_imageFile);
      });

      // Await the completion of the upload task

      final snapshot = await uploadTask!.whenComplete(() => null);

      // Get the download URL
      String downloadUrl = await storageReference.getDownloadURL();

      // Print the download URL
      print('File Uploaded: $downloadUrl');

      await FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.personalData)
          .update({'profilePic': downloadUrl});
      return downloadUrl;
    } catch (e) {
      print('File Upload Error: $e');
      return '';
    }
  }

  void updateProfileImage(String newImageUrl) {
    setState(() {
      widget.user.image = newImageUrl;
    });
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
                height: 20,
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  fit: StackFit.expand,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: ColorConstant.greyColor,
                      color: ColorConstant.greenColor,
                    ),
                    Center(
                      child: Text(
                        '${(100 * progress).roundToDouble()}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ));
          } else {
            return const SizedBox(height: 50);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    setScreenWidth(context);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 5,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          widget.user.image!.isNotEmpty
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.13,
                                  width:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: Ink(
                                      padding: const EdgeInsets.all(1),
                                      decoration: const ShapeDecoration(
                                        color: ColorConstant.whiteColor,
                                        shape: CircleBorder(),
                                      ),
                                      child: CircleAvatar(
                                          radius: 45,
                                          backgroundImage: NetworkImage(
                                              widget.user.image!))),
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.13,
                                  width:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: Ink(
                                    padding: const EdgeInsets.all(1),
                                    decoration: const ShapeDecoration(
                                      color: ColorConstant.whiteColor,
                                      shape: CircleBorder(),
                                    ),
                                    child: widget.user.gender.toLowerCase() ==
                                            GenderEnum.male
                                                .enumToString()
                                                .toLowerCase()
                                        ? Image.asset(AssetHelper.boyAvatar)
                                        : Image.asset(AssetHelper.girlAvatar),
                                  ),
                                ),
                          Positioned(
                            bottom: -10,
                            left: 70,
                            child: IconButton(
                                tooltip: TextConstant.editProfilePicture,
                                padding: EdgeInsets.zero,
                                color: Theme.of(context).colorScheme.onSurface,
                                onPressed: () {
                                  showImagePickerOption(context);
                                },
                                icon: const Icon(Icons.add_a_photo)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(
                                '${widget.user.firstName} ${widget.user.lastName}',
                                style: TextStyle(
                                    fontSize: screenWidth * 7,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (widget.user.role.toLowerCase() ==
                              RoleEnum.student.enumToString().toLowerCase())
                            Text(
                                '${widget.user.role}   |   ${widget.user.school}   |   Year ${widget.user.year}',
                                style: TextStyle(
                                    fontSize: screenWidth * 4,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer)),
                          if (widget.user.role.toLowerCase() ==
                              RoleEnum.teacher.enumToString().toLowerCase())
                            Text(
                                '${widget.user.role}   |   ${widget.user.school}',
                                style: TextStyle(
                                    fontSize: screenWidth * 4,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ]),
    );
  }
}
