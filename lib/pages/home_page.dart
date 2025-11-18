import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import './controllers/task_controller.dart';
import './controllers/category_controller.dart';
import 'widgets/task_dialogs.dart';
import './category_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  // buat bikin teks countdown
  String _getDueText(DateTime? dueDate) {
    if (dueDate == null) {
      return '';
    }

    final now = DateTime.now();
    // Hitung selisih hari, abaikan jamnya
    final difference = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference > 1) {
      return 'Due in $difference days';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference == 0) {
      return 'Due today';
    } else {
      // Kalo negatif, berarti udah lewat
      return 'Overdue by ${-difference} days';
    }
  }

  // buat nentuin warna teks
  Color _getDueTextColor(DateTime? dueDate) {
    if (dueDate == null) {
      return Colors.grey; // Warna netral
    }

    final now = DateTime.now();
    final difference = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference < 0) {
      return Colors.red; // Merah buat yang lewat deadline
    } else if (difference == 0) {
      return Colors.orange; // Oranye buat yang hari ini
    } else {
      return Colors.grey[600]!; // Abu-abu buat yang masih lama
    }
  }
  
  @override
  Widget build(BuildContext context) {
     // 1. PAKAI CONSUMER UNTUK DUA CONTROLLER
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        // 2. DI DALAMNYA, PAKAI CONSUMER LAGI BUAT CATEGORY
        return Consumer<CategoryController>(
          builder: (context, categoryController, child) {
            final taskController = Provider.of<TaskController>(context);
            final items = taskController.filteredTasks;
            final ThemeData theme = Theme.of(context);
            final Color textColor = theme.textTheme.titleLarge?.color ?? Colors.black;
            final Color hintColor = theme.hintColor;
              return Scaffold(
                appBar: AppBar(
                  title: TextField(
                    onChanged: (value) {
                      taskController.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: hintColor),
                    ),
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.category),
                      tooltip: 'Manage Categories',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CategoryPage()),
                        );
                      },
                    ),
                    PopupMenuButton<TaskFilter>(
                      onSelected: (value) => taskController.setFilter(value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: TaskFilter.all,
                          child: Text('All'),
                        ),
                        const PopupMenuItem(
                          value: TaskFilter.completed,
                          child: Text('Completed'),
                        ),
                        const PopupMenuItem(
                          value: TaskFilter.notCompleted,
                          child: Text('Not Completed'),
                        ),
                      ],
                    ),
                  ],
                ),
                body: items.isEmpty ? const Center( // if kalo gak ada task
                    child: Text(
                      'No tasks',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ReorderableListView.builder(
                  itemCount: items.length,
                  onReorder: (int oldIndex, int newIndex) {
                    taskController.reorderTasks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // CARI KATEGORI BERDASARKAN ID
                    final category = item.categoryId != null
                        ? categoryController.categories
                            .where((c) => c.id == item.categoryId)
                            .firstOrNull
                        : null;

                    return Card(
                      key: ValueKey(item.id),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isDone,
                            onChanged: (_) => taskController.toggleTask(item.id),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          // priority
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Priority: ${item.priority.name.toUpperCase()}',
                                style: TextStyle(
                                  color: _getPriorityColor(item.priority),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // BUAT TAMPILIN TANGGAL
                              if (item.dueDate != null)
                                Text(
                                  _getDueText(item.dueDate),
                                  style: TextStyle(
                                    color: _getDueTextColor(item.dueDate),
                                    fontWeight: FontWeight.bold, // Gue bold biar lebih kelihatan
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (item.notes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item.notes,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              // category
                              if (category != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 6,
                                        backgroundColor: category.color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          color: category.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // edit button
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => TaskDialogs.showEditDialog(context, item),
                              ),

                              // delete button
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => taskController.deleteTask(item.id),
                              ),
                            ],
                          ),
                          
                        )
                      );
                    },
                  ),
              floatingActionButton: FloatingActionButton( // button buat tambah
                child: const Icon(Icons.add),
                onPressed: () {
                  TaskDialogs.showAddDialog(context);
                },
              ),
            );
          },
        );
      },
    );
  }

}
