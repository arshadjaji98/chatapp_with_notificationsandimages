// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// final FirebaseStorage _storage = FirebaseStorage.instance;
// final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// class StoreData {
//   Future<String> uploadImageToStorage(String childName, Uint8List file) async {
//     Reference ref = _storage.ref().child(childName);
//     UploadTask uploadTask = ref.putData(file);
//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();
//     return downloadUrl;
//   }

//   Future<String> saveData({
//     required Uint8List file,
//   }) async {
//     String resp = 'Some error occurred';
//     try {
//       String imageUrl = await uploadImageToStorage('profileImage', file);

//       // Check if 'userProfile' collection exists, create it if not
//       CollectionReference userProfileCollection =
//           _firestore.collection('userProfile');
//       QuerySnapshot userProfileSnapshot = await userProfileCollection.get();
//       if (userProfileSnapshot.docs.isEmpty) {
//         // Collection doesn't exist, create it
//         await userProfileCollection.doc().set({}); // Create a dummy document
//       }

//       // Now, the collection exists, proceed to add the document
//       await userProfileCollection.add({
//         'imageLink': imageUrl,
//       });
//       resp = 'Success';
//     } catch (err) {
//       resp = err.toString();
//     }
//     return resp;
//   }
// }
