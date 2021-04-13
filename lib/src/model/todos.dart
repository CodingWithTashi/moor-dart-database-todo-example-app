
import 'package:moor/moor.dart';

@DataClassName('TodoEntry')
class Todos extends Table{
  IntColumn get id => integer().autoIncrement()();

  TextColumn get content => text()();

  DateTimeColumn get targetDate => dateTime().nullable()();

}
