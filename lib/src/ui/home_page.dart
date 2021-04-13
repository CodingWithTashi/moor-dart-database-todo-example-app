import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moor/moor.dart' as moor;
import 'package:moor_shared/src/blocs/appbloc.dart';
import 'package:moor_shared/src/database/database.dart';
import 'package:moor_shared/src/ui/todo_edit_dialog.dart';
import 'package:undo/undo.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}
class HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  TodoAppBloc get bloc => BlocProvider.of<TodoAppBloc>(context);
  final DateFormat _format = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoAppBloc, ChangeStack>(
      builder: (context, cs) => Scaffold(
        appBar: AppBar(
          title: Text('Todo list')
        ),
        body: FutureBuilder<List<TodoEntry>>(
          future: bloc.db.allTodoEntries,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            }

            final List<TodoEntry> activeTodos = snapshot.data;

            return getTodoCard(activeTodos);
          },
        ),
        bottomSheet: Material(
          elevation: 12.0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('What needs to be done?'),
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller,
                            onSubmitted: (_) => _createTodoEntry(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          color: Theme.of(context).accentColor,
                          onPressed: _createTodoEntry,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createTodoEntry() {
    if (controller.text.isNotEmpty) {
      bloc.db.insert(TodosCompanion(
        content: moor.Value(controller.text),
      ));
      controller.clear();
    }
    setState(() {

    });
  }

  //Get Todo Card
  Widget getTodoCard(List<TodoEntry> activeTodos) {
   return  ListView.builder(
      itemCount: activeTodos.length,
      itemBuilder: (context, index) {
         Widget dueDate;
        if (activeTodos[index].targetDate == null) {
          dueDate = GestureDetector(
            onTap: () {
              // BlocProvider.provideBloc(context).db.testTransaction(entry);
            },
            child: const Text(
              'No due date set',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          );
        } else {
          dueDate = Text(
            _format.format(activeTodos[index].targetDate),
            style: const TextStyle(fontSize: 12),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(activeTodos[index].content),
                      dueDate,
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => TodoEditDialog(entry: activeTodos[index]),
                    ).then((value) {
                      setState(() {

                      });
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    // We delete the entry here. Again, notice how we don't have to call setState() or
                    // inform the parent widget. The animated list will take care of this automatically.
                    bloc.db.deleteTodo(activeTodos[index]);
                    setState(() {

                    });
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
