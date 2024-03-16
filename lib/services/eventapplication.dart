import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wilson_campus_scene/services/types.dart';

class EventApplication {
  String? id;
  String? userID;
  String? eventID;
  EventApplicationRole? appliedFor;
  String? status;
  String? createdAt;
  String? updatedAt;

  EventApplication({
    this.id,
    this.userID,
    this.eventID,
    this.appliedFor,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
  factory EventApplication.fromMapWithId(String id, Map<String, dynamic> map) {
    return EventApplication(
      id: id,
      userID: map['userID'],
      eventID: map['eventID'],
      appliedFor: EventApplicationRole.values
          .firstWhere((e) => e.toString() == map['appliedFor']),
      status: map['status'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}

class EventApplicationStoreService {
  final eventApplicationStore =
      FirebaseFirestore.instance.collection('event_applications');
  Future<String> create({
    EventApplication? eventApplication,
  }) async {
    var userExist = await getApplicationByEventAndUser(
        eventApplication!.eventID!, eventApplication.userID!);
    if (userExist) {
      return "You have already applied for the event";
    }
    return await eventApplicationStore.add({
      'userID': eventApplication.userID,
      'eventID': eventApplication.eventID,
      'appliedFor': eventApplication.appliedFor.toString(),
      'status': 'pending',
      'createdAt': DateTime.now().toString(),
      'updatedAt': DateTime.now().toString(),
    }).then((value) => "Application submitted successfully");
  }

  Future<void> update({
    EventApplication? eventApplication,
  }) async {
    return await eventApplicationStore.doc(eventApplication?.id).update({
      'status': eventApplication?.status,
      'updatedAt': DateTime.now().toString(),
    });
  }

  Future<void> delete(
    String id,
  ) async {
    return await eventApplicationStore.doc(id).delete();
  }

  Future<bool> getApplicationByEventAndUser(
      String eventID, String userID) async {
    return await eventApplicationStore
        .where('eventID', isEqualTo: eventID)
        .where('userID', isEqualTo: userID)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  Stream<List<EventApplication>?> getApplicationsByEvent(String eventID) {
    return eventApplicationStore
        .where('eventID', isEqualTo: eventID)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty
            ? null
            : snapshot.docs.map((doc) {
                var eventApplication =
                    EventApplication.fromMapWithId(doc.id, doc.data());
                return eventApplication;
              }).toList());
  }

  Stream<List<EventApplication>?> getApplicationsByUser(String userID) {
    return eventApplicationStore
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty
            ? null
            : snapshot.docs.map((doc) {
                var eventApplication =
                    EventApplication.fromMapWithId(doc.id, doc.data());
                return eventApplication;
              }).toList());
  }

  Future<void> deleteByEventId(String eventID) async {
    await eventApplicationStore
        .where('eventID', isEqualTo: eventID)
        .get()
        .then((value) {
      for (var element in value.docs) {
        eventApplicationStore.doc(element.id).delete();
      }
    });
  }
}
