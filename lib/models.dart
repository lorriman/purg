/*
import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations.dart';
//import 'src/versions.dart';

part 'models.g.dart';

class ScheduleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 3, max: 64)();
  TextColumn get content => text().withLength(min: 0, max: 533)();
  TextColumn get defaultContent => text().withLength(min: 0, max: 533)();

}

@DriftDatabase(tables: [ScheduleItems])
class MyDatabase extends _$MyDatabase {

  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;


  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      //onUpgrade: _upgrade,
      beforeOpen: (details) async {
        // For Flutter apps, this should be wrapped in an if (kDebugMode) as
        // suggested here: https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime
        await validateDatabaseSchema();
      },
    );
  }

  static final _upgrade = (){};


 test(){
   return select(scheduleItems).watch();
 }

}


LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazvyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}


 */