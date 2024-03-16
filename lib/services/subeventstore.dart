import 'package:cloud_firestore/cloud_firestore.dart';

class SubEvent {
  String? id;
  String? eventID;
  String? title;
  String? description;
  DateTime? registrationStartDate;
  DateTime? registrationEndDate;
  DateTime? startDate;
  DateTime? endDate;
  bool? hasParticipants;

  SubEvent({
    this.id,
    this.eventID,
    this.title,
    this.description,
    this.registrationStartDate,
    this.registrationEndDate,
    this.startDate,
    this.endDate,
    this.hasParticipants,
  });
  factory SubEvent.fromMapWithId(String id, Map<String, dynamic> map) {
    return SubEvent(
      id: id,
      eventID: map['eventID'],
      title: map['title'],
      description: map['description'],
      registrationStartDate: (map['registrationStartDate']) != null
          ? DateTime.parse(map['registrationStartDate'])
          : null,
      registrationEndDate: map['registrationEndDate'] != null
          ? DateTime.parse(map['registrationEndDate'])
          : null,
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      hasParticipants: map['hasParticipants'],
    );
  }
}

class SubEventStoreService {
  final subeventsStore = FirebaseFirestore.instance.collection('subevents');
  Future<void> create({
    SubEvent? subEvent,
  }) async {
    await subeventsStore.add({
      'eventID': subEvent?.eventID,
      'title': subEvent?.title,
      'description': subEvent?.description,
      'registrationStartDate': subEvent?.registrationStartDate.toString(),
      'registrationEndDate': subEvent?.registrationEndDate.toString(),
      'startDate': subEvent?.startDate.toString(),
      'endDate': subEvent?.endDate.toString(),
      'hasParticipants': subEvent?.hasParticipants,
    });
  }

  Future<void> update({
    SubEvent? subEvent,
  }) async {
    await subeventsStore.doc(subEvent?.id).update({
      'title': subEvent?.title,
      'description': subEvent?.description,
      'registrationStartDate': subEvent?.registrationStartDate.toString(),
      'registrationEndDate': subEvent?.registrationEndDate.toString(),
      'startDate': subEvent?.startDate.toString(),
      'endDate': subEvent?.endDate.toString(),
      'hasParticipants': subEvent?.hasParticipants,
    });
  }

  Future<void> delete(
    String? id,
  ) async {
    await subeventsStore.doc(id).delete();
  }

  Stream<List<SubEvent>> getAll(String eventID) {
    return subeventsStore
        .where('eventID', isEqualTo: eventID)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var subEvent = SubEvent.fromMapWithId(doc.id, doc.data());
              return subEvent;
            }).toList());
  }

  Stream<SubEvent> get(String id) {
    return subeventsStore.doc(id).snapshots().map(
        (snapshot) => SubEvent.fromMapWithId(snapshot.id, snapshot.data()!));
  }
}
