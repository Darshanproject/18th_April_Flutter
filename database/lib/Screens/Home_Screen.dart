import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<sql.Database> db() async {
    return sql.openDatabase('Flutter.db'
    version:1,
    onCreate(sql.Database database,int version)async{
      await createTabel(database);
    }
    );
  }
  static Future<void>createTables(sql.Database database)async{
    await database.excute("""
          CREATE TABLE item(
            ID INTEGER PRIMARY KEY AUOTINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            create TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
          )
""");
  }
static Future<int>createItem(String? title String? description)async{
  final db =await DatabaseHelper.db();
  final data={'title':title,'description':description};
  final id=await db.insert('items',data,
  conflictAlgorithm :ConflictAlgorithm.replace 
  );
  return id;
}
static Future<List<Map<String,dynamic>>>getItems()async{
  final db=await DatabaseHelper.db();
  return db.query('items',orderedBy:"id");
}

static Future<int>updateItem(
  int id,String? title,String? description
)async{
  final db=await DatabaseHelper.db();
  final data={
    'title':title,
    'description':description,
    'createdAt':DateTime.now().toString()
  };
}

}


