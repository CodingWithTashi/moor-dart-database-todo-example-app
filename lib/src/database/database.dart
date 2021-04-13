// don't import moor_web.dart or moor_flutter/moor_flutter.dart in shared code
import 'package:moor/moor.dart';
import 'package:moor_shared/src/model/todos.dart';
import 'package:undo/undo.dart';
import '../database/db_utils.dart';
part 'database.g.dart';

@UseMoor(
  tables: [Todos],
  queries: {
    '_resetCategory': 'UPDATE todos SET category = NULL WHERE category = ?',
  },
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);
  final cs = ChangeStack();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(todos, todos.targetDate);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          //add dummy data
          await into(todos).insert(TodosCompanion(
            content: const Value('This is an example of moor library'),
            targetDate: Value(DateTime.now()),
          ));
          //add dummy data
          await into(todos).insert(
            TodosCompanion(
              content: const Value('This application will work in all device'),
              targetDate: Value( DateTime.now().add(const Duration(days: 4)), ),
            ),
          );
        }
      },
    );
  }
  // Get all todo
  Future<List<TodoEntry>> get allTodoEntries => select(todos).get();


  //insert todo
  Future<void> insert(object) async {

    final _todos = await (select(todos)
      ..orderBy([
            (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
      ]))
        .get();
    object = object.copyWith(id: Value(_todos.isNotEmpty?(_todos.first.id + 1):0));
    insertRow(cs,todos, object as TodosCompanion);

    //await db.createEntry(object as TodosCompanion);
    //emit(db.cs);
  }
  //delete todo
  void deleteTodo(object) {
    deleteRow(cs,todos,object as TodoEntry);
  }
  //update todo
  void updateTodo(object) {
    updateRow(cs,todos,object as TodoEntry);
  }
}