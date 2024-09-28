import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:todo/features/todo/todo.dart';
import 'package:todo/features/todo/todo_repository.dart';
import 'package:todo/shared/date_service.dart';

/// the viewmodel which is responsible for business logic of the page
/// this should be fully unit testable and dependencies should be constructor injected
class TodoPageViewModel {
  TodoPageViewModel(
      {required DateService dateService,
      required TodoRepository todoRepository})
      : _dateService = dateService,
        _todoRepository = todoRepository;

  final DateService _dateService;
  final TodoRepository _todoRepository;

  ValueNotifier<DateTime> get serviceDate => _dateService.dateNotifier;

  final ValueNotifier<List<Todo>> todosNotifier = ValueNotifier([]);
  final ValueNotifier<bool> showCompletedTodosNotifier = ValueNotifier(false);

  StreamSubscription<List<Todo>>? _subscription;

  bool get hasNonCompletedTodos =>
      todosNotifier.value.where((element) => element.completed).isNotEmpty;

  void init() {
    _listenToTodos();
  }

  void _listenToTodos() {
    final stream = _todoRepository.listenAll();

    _subscription = stream.listen(
      (todos) {
        todosNotifier.value = todos;
      },
    );
  }

  Future<void> add({required String title}) async {
    _todoRepository.addTodo(title: title);
  }

  Future<void> remove(Todo todo) async {
    _todoRepository.removeTodo(todo);
  }

  Future<void> toggleDone(Todo todo) async {
    _todoRepository.toggleDone(todo);
  }

  void toggleCompletedTodos() {
    showCompletedTodosNotifier.value = !showCompletedTodosNotifier.value;
  }

  void updateServiceDate() {
    _dateService.updateDate();
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
