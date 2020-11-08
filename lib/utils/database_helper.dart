import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:basic_note/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;  // Singleton DatabaseHelper
  static Database _database;  // Singleton Database
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  // Named constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if(_database == null)
      _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    // Get the directory path for both the Android and iOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/Create the database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
            '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)'
    );
  }

  // Select operation : Get all notes from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    // var result = db.rawQuery('SELECT * FROM $noteTable ORDER BY $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert operation: Insert a Note object into the database
  Future<int> insertNote(Note note) async {
    var db = await this.database;
    int result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update operation: Update a Note object and save it into database
  Future<int> updateNote(Note note) async {
    var db = await database;
    int result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete operation: Delete a Note object from database
  Future<int> deleteNote(Note note) async {
    var db = await database;
    int result = await db.delete(noteTable, where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Get number of Note objects from the database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the List<Map> and convert it to List<Note>
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    List<Note> noteList = List<Note>();

    for(int i = 0; i < noteMapList.length; i++)
      noteList.add(Note.fromMapObject(noteMapList[i]));
    return noteList;
  }
}