import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'devTodos.dart';

part 'driftModel.g.dart';
//part 'provider.g.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final getTodoItemsProvider = FutureProvider<List<TodoItem>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllTodoItems();
});

//@DataClassName('TodoItem')
class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 36, max: 50)();
  TextColumn get subTitle => text().withLength(min: 1, max: 100)();
  TextColumn get shortPrayer => text().withLength(min: 1, max: 255)();
  TextColumn get mediumPrayer => text().withLength(min: 1, max: 500)();
  TextColumn get longPrayer => text().withLength(min: 1, max: 4000)();
  TextColumn get userPrayer => text().withLength(min: 1, max: 4000)();

  BoolColumn get enableSchedule =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

//@DataClassName('ScheduleItem')
class ScheduleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get todoItemId => integer().references(TodoItems, #id)();
  IntColumn get dayOfWeek => integer()();
  DateTimeColumn get timeOfDay => dateTime()();
}

@DriftDatabase(tables: [TodoItems, ScheduleItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<TodoItem>> getAllTodoItems() => select(todoItems).get();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        // your existing beforeOpen callback, enable foreign keys, etc.

        if (details.wasCreated) {
          // Create a bunch of default values so the app doesn't look too empty
          // on the first start.
          await batch((b) {
            devtodos.forEach((k, e) {
              b.insert(
                todoItems,
                TodoItemsCompanion.insert(
                  title: k,
                  subTitle: e,
                  shortPrayer: "short prayer",
                  mediumPrayer: "medium prayer",
                  longPrayer: "long prayer",
                  userPrayer: "uaer prayer",
                  enableSchedule: Value(false),
                  deleted: Value(false),
                ),
              );
            });
/*
    b.insertAll(todoEntries, [
    TodoEntriesCompanion.insert(description: 'Check out drift'),
    TodoEntriesCompanion.insert(
    description: 'Fix session invalidation bug',
    category: const Value(1)),
    TodoEntriesCompanion.insert(
    description: 'Add favorite movies to home page'),
    ]);
    });
*/
          });
          if (kDebugMode) {
            // This check pulls in a fair amount of code that's not needed
            // anywhere else, so we recommend only doing it in debug builds.
            await validateDatabaseSchema();
            final wrongForeignKeys =
                await customSelect('PRAGMA foreign_key_check').get();
            assert(wrongForeignKeys.isEmpty,
                '${wrongForeignKeys.map((e) => e.data)}');
          }
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the dueDate property in the change from version 1 to
          // version 2
          //await m.addColumn(todos, todos.dueDate);
        }
        if (from < 3) {
          // we added the priority property in the change from version 1 or 2
          // to version 3
          //await m.addColumn(todos, todos.priority);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
