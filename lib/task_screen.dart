import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'utils.dart';

class taskscreen extends StatefulWidget {
  const taskscreen({super.key});

  @override
  State<taskscreen> createState() => _taskscreenState();
}

class _taskscreenState extends State<taskscreen> {
  final titlecontroller = TextEditingController();
  final descriptioncontroller = TextEditingController();
  final edittitlecontroller = TextEditingController();
  final editdescriptioncontroller = TextEditingController();
  final serachfilter = TextEditingController();
  // void dispose() {
  //   super.dispose();
  //   titlecontroller.dispose();
  //   descriptioncontroller.dispose();
  // }

  final databaseref = FirebaseDatabase.instance.ref('Task');
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Task').child('TaskList');

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text('My Todo List'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: TextFormField(
                controller: serachfilter,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
              ),
            ),
            Expanded(
              child: FirebaseAnimatedList(
                  query: ref,
                  itemBuilder: (context, snapshot, animatedlist, index) {
                    final title =
                        Text(snapshot.child('title').value.toString());
                    final desc = Text(snapshot.child('des').value.toString());
                    String id = snapshot.child('id').value.toString();

                    if (serachfilter.text.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: ListTile(
                          trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                        value: 1,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.pop(context);

                                            _showupdatedialogue(
                                                title.data.toString(),
                                                desc.data.toString(),
                                                id);
                                          },
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit'),
                                        )),
                                    PopupMenuItem(
                                        value: 1,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            ref.child(id).remove();
                                          },
                                          leading: Icon(
                                              Icons.delete_outline_rounded),
                                          title: Text('Delete'),
                                        ))
                                  ]),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              index.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          subtitle:
                              Text(snapshot.child('des').value.toString()),
                          title: Text(snapshot.child('title').value.toString()),
                        ),
                      );
                    } else if (title
                        .toString()
                        .toLowerCase()
                        .contains(serachfilter.text.toLowerCase())) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              index.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          subtitle:
                              Text(snapshot.child('des').value.toString()),
                          title: Text(snapshot.child('title').value.toString()),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            _showdialogue(context);
          }),
    );
  }

  Future<void> _showupdatedialogue(String title, String desc, String id) async {
    edittitlecontroller.text = title;
    editdescriptioncontroller.text = desc;
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: edittitlecontroller,
                  decoration: const InputDecoration(
                    hintText: 'Edit title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: editdescriptioncontroller,
                  decoration: const InputDecoration(
                    hintText: 'Edit Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.child(id).update({
                    'title': edittitlecontroller.text.toLowerCase(),
                    'des': editdescriptioncontroller.text.toLowerCase()
                  }).then((value) {
                    utils.toastmessage('Task update');
                  }).onError((error, stackTrace) {
                    utils.toastmessage(e.toString());
                  }).then((value) {
                    Navigator.pop(context);
                  });
                },
                child: Text('Edit'),
              ),
              TextButton(onPressed: () {}, child: Text('Cancel'))
            ],
          );
        });
  }

  Future<void> _showdialogue(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titlecontroller,
                  decoration: const InputDecoration(
                    hintText: 'Add title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptioncontroller,
                  decoration: const InputDecoration(
                    hintText: 'Add Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String id = DateTime.now().microsecondsSinceEpoch.toString();
                  databaseref.child('TaskList').child(id).set({
                    'title': titlecontroller.text,
                    'des': descriptioncontroller.text,
                    'id': id
                  }).then((value) {
                    utils.toastmessage('Task added');
                    setState(() {
                      loading = false;
                    });
                  }).onError((error, stackTrace) {
                    error.toString();
                  }).then((value) {
                    Navigator.pop(context);
                    titlecontroller.clear();
                    descriptioncontroller.clear();
                  });
                },
                child: Text('Add'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }
}
