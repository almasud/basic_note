import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:basic_note/models/note.dart';
import 'package:basic_note/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper databaseHelper = DatabaseHelper();
  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        // Code executes while user press the back navigation button of the device.
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          // Customize the default back button
          leading: IconButton(icon: Icon(Icons.arrow_back_ios,),
            onPressed: () {
              // Code executes while user press the back navigation button of the App bar.
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              // First element
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('Value selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),

              // Second element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),

              // Third element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description text field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),

              // Forth element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text('Save', textScaleFactor: 1.5,),
                        onPressed: () {
                          setState(() {
                            debugPrint('Save button clicked');
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(width: 5.0,),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text('Delete', textScaleFactor: 1.5,),
                        onPressed: () {
                          setState(() {
                            debugPrint('Save delete clicked');
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the string priority in the form of integer before saving it to Database.
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert the int priority in the form of stings before display it to the user in dropdown.
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];  // High
        break;
      case 2:
        priority = _priorities[1]; // Low
        break;
    }
    return priority;
  }

  // Update the title of Note Object
  void updateTitle() {
    debugPrint("Title: ${titleController.text}");
    note.title = titleController.text;
  }

  // Update the description of Note Object
  void updateDescription() {
    debugPrint("Description: ${descriptionController.text}");
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    int result;
    note.date = DateFormat.yMMMd().format(DateTime.now());
    if(note.id != null) {
      // Update operation
      result = await databaseHelper.updateNote(note);
    } else {
      // Create operation
      result = await databaseHelper.insertNote(note);
    }

    if(result != 0) {
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      _showAlertDialog('Status', 'Problem for saving Note');
    }
  }

  // Delete an existing note
  void _delete() async {
    moveToLastScreen();

    if(note.id == null) {
      _showAlertDialog("Status", "No Note was deleted");
      return;
    }

    int result = await databaseHelper.deleteNote(note);
    if(result != 0) {
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error occurred while deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}