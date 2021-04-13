import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moor_shared/src/database/dbconfig/shared.dart';
import 'package:moor_shared/src/ui/home_page.dart';
import 'src/blocs/appbloc.dart';
import 'plugins/desktop/desktop.dart';
import 'src/database/database.dart';

void main() {
  setTargetPlatformForDesktop();
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //RepositoryProvider to provide db
    return RepositoryProvider<Database>(
      //init db for web,phone,windows
      create: (context) => constructDb(),
      child: BlocProvider<TodoAppBloc>(
        create: (context) {
          final db = RepositoryProvider.of<Database>(context);
          return TodoAppBloc(db);
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: true,
          title: 'Moor Test',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomePage(),
        ),
      ),
    );
  }
}
