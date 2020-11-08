import 'package:basic_note/screens/note_detail.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:basic_note/models/note.dart';
import 'package:basic_note/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if(noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToNoteDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(noteList[position].priority),
              child: getPriorityIcon(noteList[position].priority),
            ),
            title: Text(noteList[position].title, style: titleStyle,),
            subtitle: Text(noteList[position].date),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey,),
              onTap: () {
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              debugPrint('ListTile tapped.');
              navigateToNoteDetail(this.noteList[position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  void navigateToNoteDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if(result == true) {
      updateListView();
    }
  }

  // Return the priority color
  Color getPriorityColor(int priority) {
    switch(priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  // Return the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
      case 2:
        return Icon(Icons.keyboard_arrow_right);
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note);
    if(result != 0) {
      _showSnackBar(context, 'Note deleted successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initDatabase();

    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((value) {
        setState(() {
          this.noteList = value;
          this.count = noteList.length;
        });
      });
    });
  }
}