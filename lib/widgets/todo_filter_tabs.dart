import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_filter.dart';
import '../providers/todo_notifier.dart';

class TodoFilterTabs extends ConsumerWidget {
  const TodoFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(todoFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SegmentedButton<TodoFilter>(
        segments: const [
          ButtonSegment(value: TodoFilter.all, label: Text('すべて')),
          ButtonSegment(value: TodoFilter.active, label: Text('未完了')),
          ButtonSegment(value: TodoFilter.completed, label: Text('完了済み')),
        ],
        selected: {currentFilter},
        onSelectionChanged: (newSelection) {
          ref.read(todoFilterProvider.notifier).setFilter(newSelection.first);
        },
      ),
    );
  }
}
