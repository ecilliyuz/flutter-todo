import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/todo_viewmodel.dart';

class DeletedTodosView extends StatefulWidget {
  const DeletedTodosView({super.key});

  @override
  State<DeletedTodosView> createState() => _DeletedTodosViewState();
}

class _DeletedTodosViewState extends State<DeletedTodosView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TodoViewModel>().loadDeletedTodos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silinen Görevler'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.deletedTodos.isEmpty) {
            return const Center(
              child: Text('Silinen görev bulunmamaktadır'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.deletedTodos.length,
            itemBuilder: (context, index) {
              final todo = viewModel.deletedTodos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    todo.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(todo.description),
                      const SizedBox(height: 4),
                      Text(
                        'Silinme Tarihi: ${todo.deletedAt?.toLocal().toString().substring(0, 16) ?? 'Bilinmiyor'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () {
                          viewModel.restoreTodo(todo.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Görev geri yüklendi'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () {
                          viewModel.deleteTodo(todo.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Görev kalıcı olarak silindi'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
