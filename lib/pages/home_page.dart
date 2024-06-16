import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_route.dart';
import '../provider/to_do_list_provider.dart';
import '../widgets/item_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ToDoListProvider>(context, listen: false);
    provider.load().then(
      (_) {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ToDoListProvider>(context, listen: true);
    final items = provider.listItems;
    final categories = provider.categoryItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String category) {
              provider.setCategory(category);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: "Todos",
                  child: Text("Todos"),
                ),
                ...categories.map((String category) {
                  return PopupMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoute.newItem.route);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => Dismissible(
                key: GlobalKey(),
                background: Container(color: Colors.red,),
                confirmDismiss: (_) {
                  return showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Confirmação'),
                        content: const Text('Confirmar a remoção do item?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop<bool>(context, true);
                            },
                            child: const Text('Sim'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop<bool>(context, false);
                            },
                            child: const Text('Não'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (_) {
                  provider.delete(items[index].id);
                },
                child: ItemTile(items[index]),
              ),
            ),
    );
  }
}
