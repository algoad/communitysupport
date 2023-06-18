import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communitysupport/services/models.dart';
import 'package:rxdart/rxdart.dart';

import 'auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reads all documments from the topics collection
  Future<List<Topic>> getTopics() async {
    var ref = _db.collection('topics');
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    var topics = data.map((d) => Topic.fromJson(d));
    return topics.toList();
  }

  Future<List<Alert>> getAlerts() async {
    var ref = _db.collection('alerts');
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    var alerts = data.map((d) => Alert.fromJson(d));
    return alerts.toList();
  }

  /// Listens to current user's report document in Firestore
  Stream<Report> streamReport() {
    return AuthService().userStream.switchMap((user) {
      if (user != null) {
        var ref = _db.collection('reports').doc(user.uid);
        return ref.snapshots().map((doc) => Report.fromJson(doc.data()!));
      } else {
        return Stream.fromIterable([Report()]);
      }
    });
  }

  /// Updates the current user's data in the userData collection
  Future<void> updateUserData(String name, String phoneNumber) {
    var user = AuthService().user!;
    var ref = _db.collection('userData').doc(user.uid);

    var data = {'name': name, 'phoneNumber': phoneNumber};

    return ref.set(data, SetOptions(merge: true));
  }
}
