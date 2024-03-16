import 'package:cloud_firestore/cloud_firestore.dart';

enum WilsonUserRole { admin, student }

WilsonUserRole stringToWilsonUserRole(String roleString) {
  switch (roleString) {
    case 'WilsonUserRole.admin':
      return WilsonUserRole.admin;
    case 'WilsonUserRole.student':
      return WilsonUserRole.student;
    default:
      throw ArgumentError('Invalid role string: $roleString');
  }
}

class WilsonUser {
  String? id;
  String? userID;
  String? name;
  String? email;
  WilsonUserRole? role;
  String? year;
  String? department;

  WilsonUser({
    this.id,
    this.userID,
    this.name,
    this.email,
    this.role,
    this.year,
    this.department,
  });
  factory WilsonUser.fromMapWithId(String id, Map<String, dynamic> map) {
    return WilsonUser(
      id: id,
      userID: map['userID'],
      name: map['name'],
      email: map['email'],
      role: stringToWilsonUserRole(map['role']),
      year: map['year'],
      department: map['department'],
    );
  }
}

class WilsonUserStoreService {
  final usersStore = FirebaseFirestore.instance.collection('users');
  Future<void> create({
    WilsonUser? user,
  }) async {
    final hasUser = await usersStore
        .where('userID', isEqualTo: user?.userID)
        .get()
        .then((value) => value.docs.isNotEmpty);
    if (hasUser) {
      return;
    }
    await usersStore.add({
      'userID': user?.userID,
      'name': user?.name,
      'email': user?.email,
      'role': user?.role.toString(),
      'year': user?.year,
      'department': user?.department,
    });
  }

  Stream<WilsonUser?> get(String userID) {
    return usersStore
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null; // User not found
      } else {
        return WilsonUser.fromMapWithId(
            snapshot.docs[0].id, snapshot.docs[0].data());
      }
    });
  }

  Future<void> update(WilsonUser? user) async{
    await usersStore
        .where('userID', isEqualTo: user?.id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        usersStore.doc(value.docs[0].id).update({
          'year': user?.year,
          'department': user?.department,
        });
      }
    });
    
  }

  Future<void> delete(String id) {
    return usersStore.doc(id).delete();
  }
}
