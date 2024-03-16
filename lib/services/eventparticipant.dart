import 'package:cloud_firestore/cloud_firestore.dart';

class EventParticipant {
  String? id;
  String? eventId;
  String? userId;
  String? status;
  String? createdAt;
  String? updatedAt;

  EventParticipant(
      {this.id,
      this.eventId,
      this.userId,
      this.status,
      this.createdAt,
      this.updatedAt});

  factory EventParticipant.fromMapWithId(String id, Map<String, dynamic> json) {
    return EventParticipant(
        id: json['id'],
        eventId: json['event_id'],
        userId: json['user_id'],
        status: json['status'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at']);
  }
}

class EventParticipantStoreService {
  final eventParticipantsStore =
      FirebaseFirestore.instance.collection('event_participants');
  Future<String> create({
    EventParticipant? eventParticipant,
  }) async {
    bool doesEventParticipantExist = await hasUserParticipated(
        eventParticipant!.eventId!, eventParticipant.userId!);
    if (doesEventParticipantExist) {
      return "You have already participated in the event";
    }
    return await eventParticipantsStore.add({
      'event_id': eventParticipant.eventId,
      'user_id': eventParticipant.userId,
      'status': "pending",
      'created_at': DateTime.now().toString(),
      'updated_at': DateTime.now().toString(),
    }).then((value) => "Participation submitted successfully");
  }

  Future<void> update({
    EventParticipant? eventParticipant,
  }) async {
    await eventParticipantsStore.doc(eventParticipant?.id).update({
      'status': eventParticipant?.status,
      'updated_at': DateTime.now().toString(),
    });
  }

  Future<void> delete(String id) async {
    await eventParticipantsStore.doc(id).delete();
  }

  Stream<List<EventParticipant>> getAll(String eventId) {
    return eventParticipantsStore
        .where('event_id', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var eventParticipant =
                  EventParticipant.fromMapWithId(doc.id, doc.data());
              eventParticipant.id = doc.id;
              return eventParticipant;
            }).toList());
  }

  Stream<List<EventParticipant>> getAllByUser(String userId) {
    return eventParticipantsStore
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var eventParticipant =
                  EventParticipant.fromMapWithId(doc.id, doc.data());
              eventParticipant.id = doc.id;
              return eventParticipant;
            }).toList());
  }

  Stream<List<EventParticipant>> getAllByEvent(String eventId) {
    return eventParticipantsStore
        .where('event_id', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var eventParticipant =
                  EventParticipant.fromMapWithId(doc.id, doc.data());
              eventParticipant.id = doc.id;
              return eventParticipant;
            }).toList());
  }

  Future<bool> hasUserParticipated(String eventId, String userId) {
    return eventParticipantsStore
        .where('event_id', isEqualTo: eventId)
        .where('user_id', isEqualTo: userId)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  Future<void> deleteByEventId(String eventId) async {
    await eventParticipantsStore
        .where('event_id', isEqualTo: eventId)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              eventParticipantsStore.doc(element.id).delete();
            },
          ),
        );
  }
}
