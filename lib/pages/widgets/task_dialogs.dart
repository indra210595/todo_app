import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../controllers/category_controller.dart';
import '../../models/task.dart';

class TaskDialogs {
  static void showAddDialog(BuildContext context) {
    final textController = TextEditingController();
    final taskController = Provider.of<TaskController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);

    TaskPriority? selectedPriority = TaskPriority.medium;
    DateTime? selectedDate;
    String? selectedCategoryId;

    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: StatefulBuilder(
            builder: (context, setState) {
              //CEK APAKAH ADA KATEGORI
              if (categoryController.categories.isEmpty) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('No categories yet. Please add one first.'),
                    SizedBox(height: 16),
                    Text('You can add categories from the settings (placeholder).'),
                  ],
                );
              }
              return SingleChildScrollView(
                child : Column(
                  mainAxisSize: MainAxisSize.min, // Biar nggak terlalu besar
                  children: [
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(hintText: 'Task title'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    // DROPDOWN
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: TaskPriority.values.map((TaskPriority priority) {
                        return DropdownMenuItem<TaskPriority>(
                          value: priority,
                          child: Text(priority.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (TaskPriority? newValue) {
                        selectedPriority = newValue;
                      },
                    ),
                    const SizedBox(height: 16),
                    // TANGGAL
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(), // Tidak bisa pilih tanggal kemarin
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          DateTime scheduledTime;

                          // KALO TANGGAL YANG DIPILIH ADALAH HARI INI
                          if (picked.day == DateTime.now().day &&
                              picked.month == DateTime.now().month &&
                              picked.year == DateTime.now().year) {
                            // Jadwalkan 1 menit dari sekarang buat testing
                            scheduledTime = DateTime.now().add(const Duration(minutes: 1));
                          } else {
                            // KALO TANGGAL YANG DIPILIH ADALAH BESOK/LUSA
                            // Jadwalkan jam 9 pagi
                            scheduledTime = DateTime(picked.year, picked.month, picked.day, 9, 0, 0);
                          }
                          
                          // Pakai setState dari StatefulBuilder
                          setState(() {
                            selectedDate = scheduledTime;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedDate != null ? formatDate(selectedDate) : 'No Due Date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // category
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryController.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              CircleAvatar(radius: 6, backgroundColor: category.color),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategoryId = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // notes
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3, // Biar bisa lebih dari 1 baris
                    ),
                  ],
                )
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  taskController.addTask(
                    textController.text.trim(),
                    priority: selectedPriority!,
                    dueDate: selectedDate,
                    notes: notesController.text.trim(),
                    categoryId: selectedCategoryId,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static void showEditDialog(BuildContext context, task) { // edit data
    final textController = TextEditingController(text: task.title);
    final taskController = Provider.of<TaskController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);

    TaskPriority selectedPriority = task.priority;
    DateTime? selectedDate = task.dueDate;
    String? selectedCategoryId = task.categoryId;

    final notesController = TextEditingController(text: task.notes);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child : Column(
                mainAxisSize: MainAxisSize.min, // Biar nggak terlalu besar
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(hintText: 'Task title'),
                    // autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // TAMBAHKAN DROPDOWN
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: selectedPriority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: TaskPriority.values.map((TaskPriority priority) {
                      return DropdownMenuItem<TaskPriority>(
                        value: priority,
                        child: Text(priority.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (TaskPriority? newValue) {
                      if (newValue != null) {
                        setState(() {
                            selectedPriority = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(), // Pake selectedDate yang udah diisi
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != selectedDate) {
                          DateTime scheduledTime;

                          // KALO TANGGAL YANG DIPILIH ADALAH HARI INI
                          if (picked.day == DateTime.now().day &&
                              picked.month == DateTime.now().month &&
                              picked.year == DateTime.now().year) {
                            // Jadwalkan 1 menit dari sekarang buat testing
                            scheduledTime = DateTime.now().add(const Duration(minutes: 1));
                          } else {
                            // KALO TANGGAL YANG DIPILIH ADALAH BESOK/LUSA
                            // Jadwalkan jam 9 pagi
                            scheduledTime = DateTime(picked.year, picked.month, picked.day, 9, 0, 0);
                          }
                          
                          // Pakai setState dari StatefulBuilder
                          setState(() {
                            selectedDate = scheduledTime;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedDate != null ? formatDate(selectedDate) : 'No Due Date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // category
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryController.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              CircleAvatar(radius: 6, backgroundColor: category.color),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategoryId = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // notes
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                )
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('cancel')
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  taskController.editTask(
                    task.id, 
                    textController.text.trim(), 
                    priority: selectedPriority,
                    dueDate: selectedDate,
                    notes: notesController.text.trim(),
                    categoryId: selectedCategoryId,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save')
            ),
          ],
        );
      },
    );
  }

  static String getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  static String formatDate(DateTime? date) {
    if (date == null) {
        return '';
    }
    // Contoh format: 25 Dec 2023
    return '${date.day} ${getMonthAbbreviation(date.month)} ${date.year}';
  }
}