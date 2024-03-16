import 'package:flutter/material.dart';
import 'package:wilson_campus_scene/services/eventdepartmentapplication.dart';
import 'package:wilson_campus_scene/services/user.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DepartmentApplicantsPage extends StatefulWidget {
  final String departmentId;
  const DepartmentApplicantsPage({super.key, required this.departmentId});

  @override
  State<DepartmentApplicantsPage> createState() => _DepartmentApplicantsPageState();
}

class _DepartmentApplicantsPageState extends State<DepartmentApplicantsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Applicants',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<EventDepartmentApplication>?>(
          stream: EventDepartmentApplicationStoreService().getAllByDepartment(widget.departmentId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
             var applicants = snapshot.data;
            if (applicants == null || applicants.isEmpty) {
              return const Center(child: Text('No Applicants found'));
            }
            return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0 ,
                    itemBuilder: (BuildContext context, int index) {
                      return Slidable(
                        closeOnScroll: true,
                        key: Key(index.toString()),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                EventDepartmentApplicationStoreService()
                                    .delete(applicants[index].id!);
                              },
                              label: 'Delete',
                              backgroundColor: Colors.red,
                            ),
                          ],
                        ),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            )),
                            child: StreamBuilder<WilsonUser?>(
                                stream: WilsonUserStoreService()
                                    .get(snapshot.data![index].userId!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Something went wrong');
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  var applicant = snapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: const Text("Name"),
                                          trailing: Text(
                                            applicant.name!,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text("Course"),
                                          trailing: Text(
                                            applicant.department!,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text("Year"),
                                          trailing: Text(
                                            applicant.year!,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text("Applied For"),
                                          trailing: Text(
                                            applicants[index].appliedFor!.name,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text("Status"),
                                          trailing: DropdownButton<String>(
                                            value: applicants[index].status,
                                            items: <String>[
                                              'pending',
                                              'accepted',
                                              'rejected'
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? value) {
                                              setState(() {
                                                applicants[index].status =
                                                    value!;
                                                EventDepartmentApplicationStoreService()
                                                    .update(
                                                        eventDepartmentApplication:
                                                            applicants[index]);
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                })),
                      );
                    });
          }),
    );
  }
}
