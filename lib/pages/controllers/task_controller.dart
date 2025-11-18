import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task.dart';
import '../services/notification_service.dart';

// task filter
enum TaskFilter{
  all,
  completed,
  notCompleted,
}


class TaskController extends ChangeNotifier {
  List<Task> tasks = [];

  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  TaskController(){
    loadTasks();
  } 

  // load tasks
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('tasks');

    if(stored != null){
      final List decoded = jsonDecode(stored);
      tasks = decoded.map((e) => Task.fromMap(e)).toList();
      notifyListeners();
    }
  }

  // save tasks
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks.map((e) => e.toMap()).toList()),
    );
  }

  // add task
  void addTask(String title, {
    required TaskPriority priority, 
    DateTime? dueDate,
    String notes = '',
    String? categoryId,
  }){
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      title: title,
      priority: priority,
      dueDate: dueDate,
      notes: notes,
      categoryId: categoryId,
    );

    tasks.add(newTask);

    // JADWALKAN NOTIFIKASI KALAU ADA DUE DATE
    if (newTask.dueDate != null) {
      // ID notifikasi harus unik, pake hashCode dari ID task
      final notificationId = newTask.id.hashCode;
      NotificationService().scheduleNotification(
        id: notificationId,
        title: 'Task Reminder: ${newTask.title}',
        body: 'Your task is due today!',
        scheduledTime: newTask.dueDate!,
      );
    }

    // sort by priority
    tasks.sort((a,b) => b.priority.index.compareTo(a.priority.index));

    saveTasks(); // call saveTasks
    notifyListeners();
  }

  // edit task
  void editTask(String id, String title, {
    required TaskPriority priority,
    DateTime? dueDate,
    String notes = '',
    String? categoryId,
  }){
    final index = tasks.indexWhere((t) => t.id == id);
    if(index != -1){
      final oldTask = tasks[index]; // Simpen data task lama

      // BATALKAN NOTIFIKASI LAMA KALAU DULunya ADA DUE DATE
      if (oldTask.dueDate != null) {
        final oldNotificationId = oldTask.id.hashCode;
        NotificationService().cancelNotification(oldNotificationId);
      }

      // update data task
      tasks[index].title = title;
      tasks[index].priority = priority;
      tasks[index].dueDate = dueDate;
      tasks[index].notes = notes;
      tasks[index].categoryId = categoryId;
      
      final updatedTask = tasks[index]; // Simpen data task yang baru

      // JADWALKAN NOTIFIKASI BARU KALAU ADA DUE DATE
      if (updatedTask.dueDate != null) {
        final newNotificationId = updatedTask.id.hashCode;
        NotificationService().scheduleNotification(
          id: newNotificationId,
          title: 'Task Reminder: ${updatedTask.title}',
          body: 'Your task is due today!',
          scheduledTime: updatedTask.dueDate!,
        );
      }

      // sort by priority
      tasks.sort((a,b) => b.priority.index.compareTo(a.priority.index));

      saveTasks();
      notifyListeners();
    }
  }

  // toggle done
  void toggleTask(String id){
    final index = tasks.indexWhere((t) => t.id == id);
    if(index != -1){
      tasks[index].isDone = !tasks[index].isDone;
      saveTasks();
      notifyListeners();
    }
  }

  // delete task
  void deleteTask(String id){
    // CARI TASK YANG AKAN DIHAPUS BUAT AMBIL ID NOTIFIKASINYA
    final taskToDelete = tasks.firstWhere((t) => t.id == id);

    // BATALKAN NOTIFIKASINYA KALAU ADA DUE DATE
    if (taskToDelete.dueDate != null) {
      final notificationId = taskToDelete.id.hashCode;
      NotificationService().cancelNotification(notificationId);
    }

    // HAPUS TASK
    tasks.removeWhere((t) => t.id == id);
    saveTasks();
    notifyListeners();
  }

  // ngatur ulang task
  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Task task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    saveTasks(); // Simpan urutan baru
    notifyListeners();
  }

  // filter task
  List<Task> get filteredTasks{
    List<Task> templist = tasks;

    switch(filter){
      case TaskFilter.all:
        // templist = List.from(tasks);
        break;
      case TaskFilter.completed:
        templist = tasks.where((t) => t.isDone).toList();
        break;
      case TaskFilter.notCompleted:
        templist = tasks.where((t) => !t.isDone).toList();
        break;
    }

     // filter by searchQuery
    if(searchQuery.isNotEmpty){
      templist = templist.where((task) {
        // Cek apakah judul atau notes mengandung query (case-insensitive)
        final titleContainsQuery = task.title.toLowerCase().contains(searchQuery.toLowerCase());
        final notesContainQuery = task.notes.toLowerCase().contains(searchQuery.toLowerCase());
        return titleContainsQuery || notesContainQuery;
      }).toList();
    }

    templist.sort((a,b) => b.priority.index.compareTo(a.priority.index));

    return templist;
  }

  TaskFilter filter = TaskFilter.all;

  void setFilter(TaskFilter value){
    filter = value;
    notifyListeners();
  }
}