import 'package:bloc/bloc.dart';
import 'package:undo/undo.dart';

import '../database/database.dart';
//Get DB instance from here
class TodoAppBloc extends Cubit<ChangeStack> {
  final Database db;
  TodoAppBloc(this.db) : super(db.cs);
}
