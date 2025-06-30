import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/services/models/story_model.dart';
import 'package:story_genie/services/models/user_profile_model.dart';

class FirebaseDBRepositoryImpl implements FirebaseDBRepository {
  FirebaseDBRepositoryImpl(this.firestoreDB, this.firebaseAuth);
  final FirebaseFirestore firestoreDB;
  final FirebaseAuth firebaseAuth;

  @override
  Future<void> addUserProfile(Map<String, dynamic> userDetails) async {
    final userId = firebaseAuth.currentUser!.uid;
    final Map<String, String?> map = {
      'phone': firebaseAuth.currentUser!.phoneNumber,
      'email': firebaseAuth.currentUser!.email,
    };
    userDetails.addAll(map);
    await firestoreDB.collection('user_profiles').doc(userId).set(userDetails);
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> userDetails) async {
    final userId = firebaseAuth.currentUser!.uid;
    await firestoreDB
        .collection('user_profiles')
        .doc(userId)
        .update(userDetails)
        .timeout(const Duration(seconds: 15));
  }

  @override
  Future<UserProfile> getUserProfile() async {
    final userId = firebaseAuth.currentUser!.uid;
    final data = await firestoreDB
        .collection('user_profiles')
        .doc(userId)
        .get()
        .timeout(const Duration(seconds: 30));
    final userData = UserProfile.fromJson(data.data()!);
    return userData;
  }

  @override
  Future<void> addStories(AiStory storyDetails) async {
    final userId = firebaseAuth.currentUser!.uid;
    final Map<String, dynamic> storyData = {
      'username': firebaseAuth.currentUser!.displayName,
      'userId': userId,
      'story': storyDetails.story,
      'title': storyDetails.title,
      'character': storyDetails.character.toLowerCase(),
      'feature_image_prompt': storyDetails.featuredImagePrompt,
      'feature_image': storyDetails.featureImage,
      'createdAt': storyDetails.createdAt,
      'savedBy': [],
    };
    await firestoreDB.collection('user_stories').add(storyData).then((
      DocumentReference doc,
    ) async {
      await firestoreDB.collection('user_stories').doc(doc.id).update({
        'id': doc.id,
      });
    });
  }

  @override
  Future<List<AiStory>> getStories(String character, AiStory? lastDoc) async {
    final userId = firebaseAuth.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> data;
    final List<AiStory> storiesList = [];
    if (character == 'all') {
      Query query = firestoreDB
          .collection('user_stories')
          .orderBy('createdAt', descending: true)
          .limit(kMaxDocsPerCallLimit);
      if (lastDoc != null) {
        query = query.startAfter([lastDoc.createdAt]);
      }

      data =
          await query.get().timeout(const Duration(seconds: 30))
              as QuerySnapshot<Map<String, dynamic>>;
    } else {
      Query query = firestoreDB
          .collection('user_stories')
          .where('character', isEqualTo: character.toLowerCase())
          .orderBy('createdAt', descending: true)
          .limit(kMaxDocsPerCallLimit);
      if (lastDoc != null) {
        query = query.startAfter([lastDoc.createdAt]);
      }

      data =
          await query.get().timeout(const Duration(seconds: 30))
              as QuerySnapshot<Map<String, dynamic>>;
    }
    if (data.docs.isNotEmpty) {
      for (final element in data.docs) {
        storiesList.add(AiStory.fromJson(element.data()));
        storiesList.last.isSaved = storiesList.last.savedBy.contains(userId);
      }
    }

    return storiesList;
  }

  @override
  Future<List<AiStory>> getEditorStories() async {
    final userId = firebaseAuth.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> data;
    final List<AiStory> storiesList = [];

    data = await firestoreDB
        .collection('editor_stories')
        .get()
        .timeout(const Duration(seconds: 30));

    if (data.docs.isNotEmpty) {
      for (final element in data.docs) {
        storiesList.add(AiStory.fromJson(element.data()));
        storiesList.last.isSaved = storiesList.last.savedBy.contains(userId);
      }
    }
    return storiesList;
  }

  @override
  Future<List<AiStory>> getMyStories(AiStory? lastDoc) async {
    final userId = firebaseAuth.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> data;
    final List<AiStory> storiesList = [];

    Query query = firestoreDB
        .collection('user_stories')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(kMaxDocsPerCallLimit);
    if (lastDoc != null) {
      query = query.startAfter([lastDoc.createdAt]);
    }
    data =
        await query.get().timeout(const Duration(seconds: 30))
            as QuerySnapshot<Map<String, dynamic>>;

    if (data.docs.isNotEmpty) {
      for (final element in data.docs) {
        storiesList.add(AiStory.fromJson(element.data()));
      }
    }
    return storiesList;
  }

  @override
  Future<List<AiStory>> getSavedStories(AiStory? lastDoc) async {
    final userId = firebaseAuth.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> data;
    QuerySnapshot<Map<String, dynamic>> savedEditorStories;
    final List<AiStory> storiesList = [];

    Query query = firestoreDB
        .collection('user_stories')
        .where('savedBy', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(kMaxDocsPerCallLimit);
    if (lastDoc != null) {
      query = query.startAfter([lastDoc.createdAt]);
    }
    data =
        await query.get().timeout(const Duration(seconds: 30))
            as QuerySnapshot<Map<String, dynamic>>;

    Query editorQuery = firestoreDB
        .collection('editor_stories')
        .where('savedBy', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(kMaxDocsPerCallLimit);
    if (lastDoc != null) {
      editorQuery = editorQuery.startAfter([lastDoc.createdAt]);
    }
    savedEditorStories =
        await editorQuery.get().timeout(const Duration(seconds: 30))
            as QuerySnapshot<Map<String, dynamic>>;

    if (savedEditorStories.docs.isNotEmpty) {
      for (final element in data.docs) {
        storiesList.add(AiStory.fromJson(element.data()));
        storiesList.last.isSaved = storiesList.last.savedBy.contains(userId);
      }
    }
    if (savedEditorStories.docs.isNotEmpty) {
      for (final element in savedEditorStories.docs) {
        storiesList.add(AiStory.fromJson(element.data()));
        storiesList.last.isSaved = storiesList.last.savedBy.contains(userId);
      }
    }
    return storiesList;
  }

  @override
  Future<void> addToSavedStories({
    String? docId,
    required bool isEditorStory,
  }) async {
    final userId = firebaseAuth.currentUser!.uid;
    if (isEditorStory) {
      await firestoreDB
          .collection('editor_stories')
          .doc(docId)
          .update({
            'savedBy': FieldValue.arrayUnion([userId]),
          })
          .timeout(const Duration(seconds: 15));
    } else {
      await firestoreDB
          .collection('user_stories')
          .doc(docId)
          .update({
            'savedBy': FieldValue.arrayUnion([userId]),
          })
          .timeout(const Duration(seconds: 15));
    }
  }

  @override
  Future<void> removeFromSavedStories({
    String? docId,
    required bool isEditorStory,
  }) async {
    final userId = firebaseAuth.currentUser!.uid;
    if (isEditorStory) {
      await firestoreDB
          .collection('editor_stories')
          .doc(docId)
          .update({
            'savedBy': FieldValue.arrayRemove([userId]),
          })
          .timeout(const Duration(seconds: 15));
    } else {
      await firestoreDB
          .collection('user_stories')
          .doc(docId)
          .update({
            'savedBy': FieldValue.arrayRemove([userId]),
          })
          .timeout(const Duration(seconds: 15));
    }
  }

  @override
  Future<void> addCreativeCredits() async {
    final userId = firebaseAuth.currentUser!.uid;
    await firestoreDB
        .collection('user_profiles')
        .doc(userId)
        .update({'credits': '30'})
        .timeout(const Duration(seconds: 15));
  }

  @override
  Future<void> deductCreativeCredits(String currentCredits) async {
    final userId = firebaseAuth.currentUser!.uid;
    await firestoreDB
        .collection('user_profiles')
        .doc(userId)
        .update({'credits': (int.parse(currentCredits) - 1).toString()})
        .timeout(const Duration(seconds: 15));
  }

  @override
  Future<String> getCreativeCredits() async {
    final userId = firebaseAuth.currentUser!.uid;
    final data = await firestoreDB
        .collection('user_profiles')
        .doc(userId)
        .get()
        .timeout(const Duration(seconds: 15));
    return UserProfile.fromJson(data.data()!).credits ?? '0';
  }
}

abstract class FirebaseDBRepository {
  Future<void> addUserProfile(Map<String, dynamic> userDetails);
  Future<void> updateUserProfile(Map<String, dynamic> userDetails);
  Future<UserProfile> getUserProfile();
  Future<void> addStories(AiStory storyDetails);
  Future<List<AiStory>> getStories(String character, AiStory? lastDoc);
  Future<List<AiStory>> getEditorStories();
  Future<List<AiStory>> getMyStories(AiStory? lastDoc);
  Future<List<AiStory>> getSavedStories(AiStory? lastDoc);
  Future<void> addToSavedStories({String? docId, required bool isEditorStory});
  Future<void> removeFromSavedStories({
    String? docId,
    required bool isEditorStory,
  });
  Future<void> addCreativeCredits();
  Future<void> deductCreativeCredits(String currentCredits);
  Future<String> getCreativeCredits();
}
