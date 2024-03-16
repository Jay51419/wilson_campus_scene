import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wilson_campus_scene/services/eventdepartment.dart';
import 'package:wilson_campus_scene/services/subeventstore.dart';

class Event {
  String? id;
  String? title;
  String? description;
  String? department;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? registrationStartDate;
  DateTime? registrationEndDate;
  bool? hasCoordinators;
  bool? hasVolunteers;
  bool? hasEventDepartments;
  bool? hasSubEvents;
  bool? hasParticipants;

  Event({
    this.id,
    this.title,
    this.description,
    this.department,
    this.startDate,
    this.endDate,
    this.registrationStartDate,
    this.registrationEndDate,
    this.hasCoordinators,
    this.hasVolunteers,
    this.hasEventDepartments,
    this.hasSubEvents,
    this.hasParticipants,
  });
  factory Event.fromMapWithId(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title'],
      description: map['description'],
      department: map['department'],
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      registrationStartDate: (map['registrationStartDate']) != null
          ? DateTime.parse(map['registrationStartDate'])
          : null,
      registrationEndDate: map['registrationEndDate'] != null
          ? DateTime.parse(map['registrationEndDate'])
          : null,
      hasCoordinators: map['hasCoordinators'],
      hasVolunteers: map['hasVolunteers'],
      hasEventDepartments: map['hasEventDepartments'],
      hasSubEvents: map['hasSubEvents'],
      hasParticipants: map['hasParticipants'],
    );
  }
}

class EventstoreService {
  final eventsStore = FirebaseFirestore.instance.collection('events');
  final subeventsStore = SubEventStoreService();
  final eventDepartmentsStore = EventDepartmentStoreService();
  Future<String> create({
    Event? event,
  }) async {
    return await eventsStore.add({
      'title': event?.title,
      'description': event?.description,
      'department': event?.department,
      'startDate': event?.startDate.toString(),
      'endDate': event?.endDate.toString(),
      'registrationStartDate': event?.registrationStartDate.toString(),
      'registrationEndDate': event?.registrationEndDate.toString(),
      'hasCoordinators': event?.hasCoordinators,
      'hasVolunteers': event?.hasVolunteers,
      'hasEventDepartments': event?.hasEventDepartments,
      'hasSubEvents': event?.hasSubEvents,
      'hasParticipants': event?.hasParticipants,
    }).then(
      (event) => event.id,
    );
  }

  Stream<List<Event>> getAll() {
    return eventsStore.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMapWithId(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<Event?> get(String eventID) {
    return eventsStore.doc(eventID).snapshots().map((snapshot) {
      return Event.fromMapWithId(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> update({
    Event? event,
  }) async {
    if (event != null) {
      await eventsStore.doc(event.id).update({
        'title': event.title,
        'description': event.description,
        'department': event.department,
        'startDate': event.startDate.toString(),
        'endDate': event.endDate.toString(),
        'registrationStartDate': event.registrationStartDate.toString(),
        'registrationEndDate': event.registrationEndDate.toString(),
        'hasCoordinators': event.hasCoordinators,
        'hasVolunteers': event.hasVolunteers,
        'hasEventDepartments': event.hasEventDepartments,
        'hasSubEvents': event.hasSubEvents,
        'hasParticipants': event.hasParticipants,
      });
    }
  }
  Future<void> delete(String eventID) async {
    await eventsStore.doc(eventID).delete();
  }
}
