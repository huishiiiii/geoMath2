import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/text_constant.dart';
import 'package:geomath/models/class_model.dart';
import 'package:geomath/models/note_model.dart';
import 'package:geomath/models/quiz_model.dart';
import 'package:geomath/models/score_model.dart';
import 'package:geomath/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseService {
  //add / update user data to the firebase
  Future addUserDetails(UserModel userModel) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (userModel.role.toLowerCase() ==
        RoleEnum.student.enumToString().toLowerCase()) {
      await FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.personalData)
          .set({
        'firstname': userModel.firstName,
        'lastname': userModel.lastName,
        'gender': userModel.gender,
        'email': userModel.email,
        'role': userModel.role,
        'school': userModel.school,
        'year': userModel.year,
        'classEnrollmentKey': userModel.classEnrollmentKey,
        'teacherName': userModel.teacherName,
      });
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(userModel.classEnrollmentKey)
          .collection(TextConstant.student)
          .doc('${user?.uid}')
          .set({
        'firstname': userModel.firstName,
        'lastname': userModel.lastName,
        'gender': userModel.gender,
        'school': userModel.school,
        'year': userModel.year,
        'teacherName': userModel.teacherName,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.personalData)
          .set({
        'firstname': userModel.firstName,
        'lastname': userModel.lastName,
        'role': userModel.role,
        'school': userModel.school,
        'gender': userModel.gender,
        'email': userModel.email,
      });
    }
  }

  //change user account password
  Future<void> changePassword(
      String newPassword, String currentPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);

        await user.reauthenticateWithCredential(credential);

        // Update the user's password
        await user.updatePassword(newPassword);
        print("Password updated successfully.");
      } else {
        print("No user signed in.");
      }
    } catch (e) {
      print("Error changing password: $e");
      // Handle the error accordingly
    }
  }

  //delete user account
  Future<void> deleteAccount(String classId, String role) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Delete the user's account
        await user.delete();
        await FirebaseFirestore.instance
            .collection(user.uid)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
        if (role.toLowerCase() ==
            RoleEnum.student.enumToString().toLowerCase()) {
          DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore
              .instance
              .collection(TextConstant.classText)
              .doc(classId)
              .collection(TextConstant.student)
              .doc(user.uid);
          await FirebaseFirestore.instance
              .collection(TextConstant.classText)
              .doc(classId)
              .collection(TextConstant.student)
              .doc(user.uid)
              .delete();
          QuerySnapshot<Map<String, dynamic>> subcollectionSnapshot =
              await docRef.collection(TextConstant.quizzes).get();

          // Delete documents in each subcollection
          for (QueryDocumentSnapshot<Map<String, dynamic>> subDocSnapshot
              in subcollectionSnapshot.docs) {
            // Delete document
            await subDocSnapshot.reference.delete();
          }
        }

        print("Account deleted successfully.");
      } else {
        print("No user signed in.");
      }
    } catch (e) {
      print("Error deleting account: $e");
      // Handle the error accordingly
    }
  }

//get user data from firebase
  Future<Map<String, dynamic>> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(uid)
        .doc(TextConstant.personalData)
        .get();

    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      // Handle case when the document doesn't exist
      return {};
    }
  }

  //get notes details from firebase
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection(TextConstant.notes).get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all notes: $error");
      return [];
    }
  }

  //get teacher notes from firebase
  Future<List<Map<String, dynamic>>> getTeacherNotes(String classId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('${user?.uid}')
              .doc(TextConstant.classes)
              .collection(TextConstant.classes)
              .doc(classId)
              .collection(TextConstant.notes)
              .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all notes: $error");
      return [];
    }
  }

  //get teacher notes details from firebase
  Future<Map<String, dynamic>> getTeacherNoteDetails(
      String classId, String topic) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(classId)
          .collection(TextConstant.notes)
          .doc(topic)
          .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      print('snapshot data: ${snapshot.data}');
      if (snapshot.exists) {
        return snapshot.data()!;
      } else {
        return {};
      }
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all notes: $error");
      return {};
    }
  }

  //get teacher's class details
  Future<List<Map<String, dynamic>>> getTeacherClasses() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('${user?.uid}')
              .doc(TextConstant.classes)
              .collection(TextConstant.classes)
              .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all notes: $error");
      return [];
    }
  }

  Future addClassEnrollmentKey(ClassModel classModel) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    try {
      //add to class collection in firebase
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(classModel
              .classEnrollmentKey) // Use the enrollment key as the document ID
          .set({
        'userId': classModel.userId,
        'year': classModel.year,
        'teacherName': classModel.teacherName,
        'schoolName': classModel.schoolName
      });
      //add to classes collection of specified user
      await FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(classModel.classEnrollmentKey)
          .set({
        'schoolName': classModel.schoolName,
        'year': classModel.year,
        'teacherName': classModel.teacherName,
      });
      print("Class Enrollment Key added successfully!");
    } catch (error) {
      // Handle any potential errors
      print("Error adding class enrollment key: $error");
    }
  }

  //get class enroll key
  Future<List<Map<String, dynamic>>> getClassEnrollmentKey() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(TextConstant.classText)
              .get();
      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all class enroll keys: $error");
      return [];
    }
  }

  //delete class
  Future<void> deleteClass(String classId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    try {
      DocumentReference<Map<String, dynamic>> docRef1 = FirebaseFirestore
          .instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(classId);
      await FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(classId)
          .delete();
      DocumentReference<Map<String, dynamic>> docRef2 = FirebaseFirestore
          .instance
          .collection(TextConstant.classText)
          .doc(classId);
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(classId) // Use the enrollment key as the document ID
          .delete();

      QuerySnapshot<Map<String, dynamic>> subcollectionSnapshotNotes =
          await docRef1.collection(TextConstant.notes).get();
      QuerySnapshot<Map<String, dynamic>> subcollectionSnapshotQuizzes =
          await docRef1.collection(TextConstant.quizzes).get();

      QuerySnapshot<Map<String, dynamic>> subcollectionSnapshotNotes2 =
          await docRef2.collection(TextConstant.notes).get();
      QuerySnapshot<Map<String, dynamic>> subcollectionSnapshotQuizzes2 =
          await docRef2.collection(TextConstant.quizzes).get();

      // Delete documents in each subcollection
      for (QueryDocumentSnapshot<Map<String, dynamic>> subDocSnapshot
          in subcollectionSnapshotNotes.docs) {
        // Delete document
        await subDocSnapshot.reference.delete();
      }
      for (QueryDocumentSnapshot<Map<String, dynamic>> subDocSnapshot
          in subcollectionSnapshotQuizzes.docs) {
        // Delete document
        await subDocSnapshot.reference.delete();
      }
      for (QueryDocumentSnapshot<Map<String, dynamic>> subDocSnapshot
          in subcollectionSnapshotNotes2.docs) {
        // Delete document
        await subDocSnapshot.reference.delete();
      }
      for (QueryDocumentSnapshot<Map<String, dynamic>> subDocSnapshot
          in subcollectionSnapshotQuizzes2.docs) {
        // Delete document
        await subDocSnapshot.reference.delete();
      }
    } catch (e) {
      throw e;
    }
  }

  // get specified class details from firebase
  Future<Map<String, dynamic>> getClassDetails(String classId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(TextConstant.classText)
        .doc(classId)
        .get();
    print('snapshot data: ${snapshot.data}');
    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      // Handle case when the document doesn't exist
      return {};
    }
  }

  // Upload image to Firebase
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Error uploading image: $e");
      // Handle the error accordingly
      throw "Error uploading image: $e";
    }
  }

  // Function to upload image to Firebase Storage
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
      UploadTask uploadTask = storageReference.putFile(_imageFile);

      // Await the completion of the upload task
      await uploadTask.whenComplete(() => null);

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

  // Get notes details from Firebase
  Future<Map<String, dynamic>> getNotesDetails(
      String topic, String? classId, String role) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection(TextConstant.notes)
          .doc(topic)
          .get();

      Map<String, dynamic> firstData = snapshot.exists ? snapshot.data()! : {};
      if (role == RoleEnum.teacher.enumToString().toLowerCase()) {
        Map<String, dynamic> combinedData = {
          ...firstData,
        };
        print('Combined data: $combinedData');
        return combinedData;
      } else {
        print('topic: $topic');
        DocumentSnapshot<Map<String, dynamic>> additionalSnapshot =
            await FirebaseFirestore.instance
                .collection(TextConstant.classText)
                .doc(classId)
                .collection(TextConstant.notes)
                .doc(topic)
                .get();
        Map<String, dynamic> additionalData =
            additionalSnapshot.exists ? additionalSnapshot.data()! : {};
        if (additionalSnapshot.exists) {
          Map<String, dynamic> combinedData = {
            ...additionalData,
          };
          return combinedData;
        } else {
          Map<String, dynamic> combinedData = {
            ...firstData,
          };
          return combinedData;
        }
      }

      // Merge the data from both documents
    } catch (error) {
      print('Error retrieving notes details: $error');
      return {};
    }
  }

  //add score
  Future addScore(ScoreModel scoreModel, String classId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    await FirebaseFirestore.instance
        .collection('${user?.uid}')
        .doc(TextConstant.quizzes)
        .collection(TextConstant.quizzes)
        .doc(scoreModel.quizId)
        .set({
      'quizName': scoreModel.quizName,
      'numQuestion': scoreModel.numQuestion,
      'score': scoreModel.score
    });
    await FirebaseFirestore.instance
        .collection(TextConstant.classText)
        .doc(classId)
        .collection(TextConstant.student)
        .doc(user?.uid)
        .collection(TextConstant.quizzes)
        .doc(scoreModel.quizId)
        .set({
      'quizName': scoreModel.quizName,
      'numQuestion': scoreModel.numQuestion,
      'score': scoreModel.score
    });
  }

  // add new note
  Future addNewNote(NoteModel noteModel) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      await FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(noteModel.classId)
          .collection(TextConstant.notes)
          .doc(noteModel.title)
          .set({
        //wonghuishi123
        'title': noteModel.title,
        'instruction': noteModel.instruction,
        'fileName': noteModel.fileName,
        'fileUrl': noteModel.fileUrl,
        'source': noteModel.source,
        'year': noteModel.year,
      });
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(noteModel.classId)
          .collection(TextConstant.notes)
          .doc(noteModel.title)
          .set({
        'title': noteModel.title,
        'instruction': noteModel.instruction,
        'fileName': noteModel.fileName,
        'fileUrl': noteModel.fileUrl,
        'source': noteModel.source,
        'year': noteModel.year,
      });
    } catch (error) {
      print("Error adding notes: $error");
      return [];
    }
  }

  //delete note
  Future deleteNote(
      NoteModel noteModel, String oldTitle, String oldClassId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    // Delete the existing document with the old title
    await FirebaseFirestore.instance
        .collection('${user?.uid}')
        .doc(TextConstant.classes)
        .collection(TextConstant.classes)
        .doc(oldClassId)
        .collection(TextConstant.notes)
        .doc(oldTitle)
        .delete();

    await FirebaseFirestore.instance
        .collection(TextConstant.classText)
        .doc(oldClassId)
        .collection(TextConstant.notes)
        .doc(oldTitle)
        .delete();
  }

  // update note
  Future updateNote(
      NoteModel noteModel, String oldTitle, String oldClassId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    // Delete the existing document with the old title
    await FirebaseFirestore.instance
        .collection('${user?.uid}')
        .doc(TextConstant.classes)
        .collection(TextConstant.classes)
        .doc(oldClassId)
        .collection(TextConstant.notes)
        .doc(oldTitle)
        .delete();

    await FirebaseFirestore.instance
        .collection(TextConstant.classText)
        .doc(oldClassId)
        .collection(TextConstant.notes)
        .doc(oldTitle)
        .delete();

    await FirebaseFirestore.instance
        .collection('${user?.uid}')
        .doc(TextConstant.classes)
        .collection(TextConstant.classes)
        .doc(noteModel.classId)
        .collection(TextConstant.notes)
        .doc(noteModel.title)
        .set({
      'title': noteModel.title,
      'instruction': noteModel.instruction,
      'fileName': noteModel.fileName,
      'fileUrl': noteModel.fileUrl,
      'source': noteModel.source,
      'year': noteModel.year,
    });
    await FirebaseFirestore.instance
        .collection(TextConstant.classText)
        .doc(noteModel.classId)
        .collection(TextConstant.notes)
        .doc(noteModel.title)
        .set({
      'title': noteModel.title,
      'instruction': noteModel.instruction,
      'fileName': noteModel.fileName,
      'fileUrl': noteModel.fileUrl,
      'source': noteModel.source,
      'year': noteModel.year,
    });
  }

  //get class note
  Future<List<Map<String, dynamic>>> getClassNotes(String classId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(TextConstant.classText)
              .doc(classId)
              .collection(TextConstant.notes)
              .get();
      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving class notes: $error");
      return [];
    }
  }

  //get quizzes details from firebase
  Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(TextConstant.quizzes)
              .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all quizzes: $error");
      return [];
    }
  }

  //get class quizzes
  Future<List<Map<String, dynamic>>> getClassQuizzes(String classId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(TextConstant.classText)
              .doc(classId)
              .collection(TextConstant.quizzes)
              .get();
      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving class quizzes: $error");
      return [];
    }
  }

  // Get quizzes details from Firebase
  Future<Map<String, dynamic>> getQuizzesDetails(
      String topic, String? classId) async {
    try {
      // Get the document snapshot from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection(TextConstant
              .quizzes) // Replace TextConstant.quizzes with your collection name string if needed
          .doc(topic)
          .get();

      DocumentSnapshot<Map<String, dynamic>> snapshot2 = await FirebaseFirestore
          .instance
          .collection(TextConstant
              .classText) // Replace TextConstant.quizzes with your collection name string if needed
          .doc(classId)
          .collection(TextConstant.quizzes)
          .doc(topic)
          .get();

      // Check if the document exists and return the data
      if (snapshot.exists) {
        return snapshot.data() ?? {};
      } else if (snapshot2.exists) {
        return snapshot2.data() ?? {};
      } else {
        // Return an empty map if the document does not exist
        return {};
      }
    } catch (e) {
      // Handle any errors that occur during the Firestore operation
      print('Error getting quiz details: $e');
      return {};
    }
  }

//Get quizzes details based on year
  Future<List<Map<String, dynamic>>> getQuizzesDetailsByYear(
      String topic, int year) async {
    try {
      // Get the collection reference
      CollectionReference<Map<String, dynamic>> collectionRef =
          FirebaseFirestore.instance.collection(TextConstant.quizzes);

      // Query the collection for documents with the specified topic and year
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionRef
          .where('topic', isEqualTo: topic)
          .where('details.year', isEqualTo: year)
          .get();

      // Check if any documents were returned
      if (querySnapshot.docs.isNotEmpty) {
        // Return the list of document data maps
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      } else {
        // Return an empty list if no documents matched the query
        return [];
      }
    } catch (e) {
      // Handle any errors that occur during the Firestore operation
      print('Error getting quiz details: $e');
      return [];
    }
  }

  // Get quizzes questions from Firebase
  Future<List<Map<String, dynamic>>> getQuizzesQuestions(
      String id, String? classId) async {
    // Reference to the 'questions' subcollection of the specific quiz document
    CollectionReference<Map<String, dynamic>> questionsCollection =
        FirebaseFirestore.instance
            .collection(TextConstant.quizzes)
            .doc(id)
            .collection(TextConstant.questions);
    CollectionReference<Map<String, dynamic>> questionsCollection2 =
        FirebaseFirestore.instance
            .collection(TextConstant
                .classText) // Replace TextConstant.quizzes with your collection name string if needed
            .doc(classId)
            .collection(TextConstant.quizzes)
            .doc(id)
            .collection(TextConstant.questions);

    // Get all documents in the 'questions' subcollection
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await questionsCollection.get();
    QuerySnapshot<Map<String, dynamic>> querySnapshot2 =
        await questionsCollection2.get();

    // Print the documents for debugging purposes
    for (var doc in querySnapshot.docs) {
      print('Document data: ${doc.data()}');
    }
    for (var doc in querySnapshot2.docs) {
      print('Document data: ${doc.data()}');
    }

    // Check if there are any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Map the documents to a list of maps
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } else if (querySnapshot2.docs.isNotEmpty) {
      // Map the documents to a list of maps
      return querySnapshot2.docs.map((doc) => doc.data()).toList();
    } else {
      return [];
    }
  }

  //get teacher quizzes from firebase
  Future<List<Map<String, dynamic>>> getTeacherQuizzes(String classId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('${user?.uid}')
              .doc(TextConstant.classes)
              .collection(TextConstant.classes)
              .doc(classId)
              .collection(TextConstant.quizzes)
              .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        final data = document.data();
        return {
          'id': document.id, // Get the document ID
          'quizname': data?['quizname'], // Get the quiz title
          ...data!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all quizzes: $error");
      return [];
    }
  }

  //get teacher quizzes questions details from firebase
  Future<List<Map<String, dynamic>>> getTeacherQuizQuestionDetails(
      String classId, String id) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(classId)
          .collection(TextConstant.quizzes)
          .doc(id)
          .collection(TextConstant.questions)
          .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving quiz questions: $error");
      return [];
    }
  }

  //get teacher quizzes details from firebase
  Future<Map<String, dynamic>> getTeacherQuizDetails(
      String classId, String topic) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(classId)
          .collection(TextConstant.quizzes)
          .doc(topic)
          .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      print('snapshot data: ${snapshot.data}');
      if (snapshot.exists) {
        return snapshot.data()!;
      } else {
        return {};
      }
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving all quizzes: $error");
      return {};
    }
  }

  //add new quiz
  Future addNewQuiz(QuizModel quizModel) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var docId = FirebaseFirestore.instance
        .collection('${user?.uid}')
        .doc(TextConstant.classes)
        .collection(TextConstant.classes)
        .doc(quizModel.classId)
        .collection(TextConstant.quizzes)
        .doc();
    await FirebaseFirestore.instance
        .collection('${user?.uid}')
        .doc(TextConstant.classes)
        .collection(TextConstant.classes)
        .doc(quizModel.classId)
        .collection(TextConstant.quizzes)
        .doc(docId.id)
        .set({
      'desc': quizModel.description,
      'question': quizModel.numberOfQuestions,
      'quizname': quizModel.title,
      'year': quizModel.year
    });
    await FirebaseFirestore.instance
        .collection(TextConstant.classText)
        .doc(quizModel.classId)
        .collection(TextConstant.quizzes)
        .doc(docId.id)
        .set({
      'desc': quizModel.description,
      'question': quizModel.numberOfQuestions,
      'quizname': quizModel.title,
      'year': quizModel.year
    });
    for (int i = 0; i < quizModel.questions!.length; i++) {
      var questionId = FirebaseFirestore.instance
          .collection('${user?.uid}')
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(docId.id)
          .collection(TextConstant.questions)
          .doc();

      await questionId
          .set({'id': questionId.id, ...quizModel.questions![i].toMap()});
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(docId.id)
          .collection(TextConstant.questions)
          .doc(questionId.id)
          .set({'id': questionId.id, ...quizModel.questions![i].toMap()});
    }
  }

  //delete quiz
  Future deleteQuiz(QuizModel quizModel) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) return;
    try {
      DocumentReference<Map<String, dynamic>> docRef1 = FirebaseFirestore
          .instance
          .collection(user.uid)
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(quizModel.quizId);

      DocumentReference<Map<String, dynamic>> docRef2 = FirebaseFirestore
          .instance
          .collection(TextConstant.classText)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(quizModel.quizId);
      // Update the quiz details in the user's class collection
      await FirebaseFirestore.instance
          .collection(user.uid)
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(quizModel.quizId)
          .delete();

      // Update the quiz details in the public class collection
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(quizModel.quizId)
          .delete();

      await docRef1.collection(TextConstant.quizzes).get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      await docRef2.collection(TextConstant.quizzes).get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      // Handle any errors that occur during the update process
      print('Error updating quiz: $e');
    }
  }

  //update quiz
  Future updateQuiz(QuizModel quizModel) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) return;
    print('Quiz ID: ${quizModel.quizId}'); // Ensure user is logged in

    try {
      // Update the quiz details in the user's class collection
      await FirebaseFirestore.instance
          .collection(user.uid)
          .doc(TextConstant.classes)
          .collection(TextConstant.classes)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(quizModel.quizId)
          .update({
        'desc': quizModel.description,
        'question': quizModel.numberOfQuestions,
        'quizname': quizModel.title,
      });

      // Update the quiz details in the public class collection
      await FirebaseFirestore.instance
          .collection(TextConstant.classText)
          .doc(quizModel.classId)
          .collection(TextConstant.quizzes)
          .doc(quizModel.quizId)
          .update({
        'desc': quizModel.description,
        'question': quizModel.numberOfQuestions,
        'quizname': quizModel.title,
      });

      // Update the questions
      for (int i = 0; i < quizModel.questions!.length; i++) {
        var question = quizModel.questions![i];
        var questionId = quizModel.questionDetails![i]['id'];

        print('Update Quiz: ${questionId}');

        if (questionId != null && questionId.isNotEmpty) {
          //Update the question in the user's class collection
          await FirebaseFirestore.instance
              .collection('${user.uid}')
              .doc(TextConstant.classes)
              .collection(TextConstant.classes)
              .doc(quizModel.classId)
              .collection(TextConstant.quizzes)
              .doc(quizModel.quizId)
              .collection(TextConstant.questions)
              .doc(questionId)
              .update(question.toMap());

          // Update the question in the public class collection
          await FirebaseFirestore.instance
              .collection(TextConstant.classText)
              .doc(quizModel.classId)
              .collection(TextConstant.quizzes)
              .doc(quizModel.quizId)
              .collection(TextConstant.questions)
              .doc(questionId)
              .update(question.toMap());
        }
      }
    } catch (e) {
      // Handle any errors that occur during the update process
      print('Error updating quiz: $e');
    }
  }

  //get quizzes performance by class
  Future<List<Map<String, dynamic>>> getClassPerformance() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      // Handle the case where user is not logged in
      return [];
    }

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(TextConstant.classText)
              .where('userId', isEqualTo: user.uid)
              .get();

      List<Map<String, dynamic>> classPerformance = [];

      for (DocumentSnapshot<Map<String, dynamic>> classDoc
          in querySnapshot.docs) {
        QuerySnapshot<Map<String, dynamic>> studentQuerySnapshot =
            await classDoc.reference.collection(TextConstant.student).get();

        List<Map<String, dynamic>> students = [];

        for (DocumentSnapshot<Map<String, dynamic>> studentDoc
            in studentQuerySnapshot.docs) {
          // Retrieve quizzes for the current student
          QuerySnapshot<Map<String, dynamic>> quizzesQuerySnapshot =
              await studentDoc.reference.collection(TextConstant.quizzes).get();

          List<Map<String, dynamic>> quizzes = [];

          quizzesQuerySnapshot.docs.forEach((quizDoc) {
            quizzes.add({
              'quizId': quizDoc.id,
              ...quizDoc.data(),
            });
          });

          // Add student details with quizzes to the list
          students.add({
            'id': studentDoc.id,
            ...?studentDoc.data(),
            'quizzes': quizzes, // Add quizzes data to the student details
          });
        }

        // Add class details with students to the overall performance data
        classPerformance.add({
          'classId': classDoc.id,
          'classData': classDoc.data(),
          'students': students,
        });
      }

      return classPerformance;
    } catch (error) {
      print("Error retrieving ${user.uid}'s classes performance: $error");
      return [];
    }
  }

  //get quizzes performance for each student
  Future<List<Map<String, dynamic>>> getStudentPerformance() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(user!.uid)
              .doc(TextConstant.quizzes)
              .collection(TextConstant.quizzes)
              .get();

      // Convert the list of QueryDocumentSnapshot to a List<Map<String, dynamic>>
      return querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        return {
          'id': document.id, // Get the document ID
          ...document.data()!, // Get the rest of the document data
        };
      }).toList();
    } catch (error) {
      // Handle any potential errors
      print("Error retrieving ${user!.uid}'s quizzes score: $error");
      return [];
    }
  }

  Future<File?> loadFirebase(String url) async {
    try {
      final refPDF = FirebaseStorage.instance.ref().child(url);
      final bytes = await refPDF.getData();

      return _storeFile(url, bytes!);
    } catch (e) {
      return null;
    }
  }

  Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
