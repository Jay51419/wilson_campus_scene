import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wilson_campus_scene/services/types.dart';


class EventDepartmentApplication {
  String? id;
  String? eventDepartmentId;
  String? eventId;
  String? userId;
  EventDepartmentApplicationRole? appliedFor;
  String? status;
  String? createdAt;
  String? updatedAt;

  EventDepartmentApplication({
    this.id,
    this.eventDepartmentId,
    this.eventId,
    this.userId,
    this.appliedFor,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory EventDepartmentApplication.fromJsonWithId(String id,Map<String, dynamic> json) {
    return EventDepartmentApplication(
      id: id,
      eventDepartmentId: json['event_department_id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      status: json['status'],
      appliedFor: EventDepartmentApplicationRole.values
          .firstWhere((e) => e.toString() == json['applied_for']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class EventDepartmentApplicationStoreService {
  final eventDepartmentApplicationStore =
      FirebaseFirestore.instance.collection('event_department_applications');
  Future<String> create({
    EventDepartmentApplication? eventDepartmentApplication,
  }) async {
    var userExist = await getApplicationByEventAndUser(
        eventDepartmentApplication!.eventId!,
        eventDepartmentApplication.userId!);
    if (userExist) {
      return "You have already applied for the department";
    }
    return await eventDepartmentApplicationStore.add({
      'event_department_id': eventDepartmentApplication.eventDepartmentId,
      'event_id': eventDepartmentApplication.eventId,
      'user_id': eventDepartmentApplication.userId,
      'applied_for': eventDepartmentApplication.appliedFor.toString(),
      'status': 'pending',
      'created_at': DateTime.now().toString(),
      'updated_at': DateTime.now().toString(),
    }).then((value) => "You have successfully applied for the department");
  }

  Future<void> update({
    EventDepartmentApplication? eventDepartmentApplication,
  }) async {
    return await eventDepartmentApplicationStore
        .doc(eventDepartmentApplication?.id)
        .update({
      'status': eventDepartmentApplication?.status,
      'updated_at': DateTime.now().toString(),
    });
  }
  Future<void>delete(String id) async {
    return await eventDepartmentApplicationStore
        .doc(id)
        .delete();
  }

  Future<bool> getApplicationByEventAndUser(
      String eventId, String userId) async {
    return await eventDepartmentApplicationStore
        .where('event_id', isEqualTo: eventId)
        .where('user_id', isEqualTo: userId)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  Stream<List<EventDepartmentApplication>> getAll(String eventId) {
    return eventDepartmentApplicationStore
        .where('event_id', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((e) => EventDepartmentApplication.fromJsonWithId(e.id,e.data()))
            .toList());
  }

  Stream<List<EventDepartmentApplication>> getAllByUser(String userId) {
    return eventDepartmentApplicationStore
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((e) => EventDepartmentApplication.fromJsonWithId(e.id,e.data()))
            .toList());
  }

  Stream<List<EventDepartmentApplication>> getAllByDepartment(
      String eventDepartmentId) {
    return eventDepartmentApplicationStore
        .where('event_department_id', isEqualTo: eventDepartmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((e) => EventDepartmentApplication.fromJsonWithId(e.id,e.data()))
            .toList());
  }
  Future<void> deleteByEventDepartmentId(String eventDepartmentId) async {
    var applications = await eventDepartmentApplicationStore
        .where('event_department_id', isEqualTo: eventDepartmentId)
        .get();
    for (var application in applications.docs) {
      eventDepartmentApplicationStore.doc(application.id).delete();
    }
  }
}
