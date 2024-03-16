import 'package:cloud_firestore/cloud_firestore.dart';

class EventDepartment {
  String? id;
  String? eventID;
  String? name;
  bool? hasVolunteers;
  bool? hasHOD;

  EventDepartment({
    this.id,
    this.eventID,
    this.name,
    this.hasVolunteers,
    this.hasHOD,
  });
  factory EventDepartment.fromMapWithId(String id, Map<String, dynamic> map) {
    return EventDepartment(
      id: id,
      eventID: map['eventID'],
      name: map['name'],
      hasVolunteers: map['hasVolunteers'],
      hasHOD: map['hasHOD'],
    );
  }
}

class EventDepartmentStoreService {
  final eventdepartmentsStore =
      FirebaseFirestore.instance.collection('event_departments');
  Future<String?> create({
    EventDepartment? eventDepartment,
  }) async {
    return await eventdepartmentsStore.add({
      'eventID': eventDepartment?.eventID,
      'name': eventDepartment?.name,
      'hasVolunteers': eventDepartment?.hasVolunteers,
      'hasHOD': eventDepartment?.hasHOD,
    }).then((value) => value.id);
  }

  Stream<List<EventDepartment>> getAll(String eventID) {
    return eventdepartmentsStore
        .where('eventID', isEqualTo: eventID)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return EventDepartment.fromMapWithId(doc.id, doc.data());
          }).toList(),
        );
  }

  Stream<EventDepartment> get(String id) {
    return eventdepartmentsStore.doc(id).snapshots().map((snapshot) =>
        EventDepartment.fromMapWithId(snapshot.id, snapshot.data()!));
  }

  Future<void> update(EventDepartment? eventDepartment) {
    return eventdepartmentsStore.doc(eventDepartment?.id).update({
      'name': eventDepartment?.name,
      'hasVolunteers': eventDepartment?.hasVolunteers,
      'hasHOD': eventDepartment?.hasHOD,
    });
  }

  Future<void> delete(String? id) {
    return eventdepartmentsStore.doc(id).delete();
  }
}
