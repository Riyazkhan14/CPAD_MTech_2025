import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../data/task_repo.dart';
import 'edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final repo = TaskRepo();
  List tasks = [];
  bool loading = true;

  Future<void> load() async {
    tasks = await repo.list();
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void showRootSnack(String msg) {
    Future.delayed(const Duration(milliseconds: 60), () {
      ScaffoldMessenger.of(
        Navigator.of(context).overlay!.context,
      ).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("My Tasks"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_arrow_right),
          onPressed: () async {
            final u = await ParseUser.currentUser() as ParseUser?;
            await u?.logout();
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      child: SafeArea(
        child: loading
            ? const Center(child: CupertinoActivityIndicator())
            : tasks.isEmpty
            ? _EmptyState(onAdd: () => _showAddSheet(context))
            : _TaskList(
          tasks: tasks,
          onToggle: (t) async {
            await repo.toggle(t);
            load();
          },
          onEdit: (t) async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => EditTaskPage(task: t),
              ),
            );
            load();
          },
          onDelete: (t) async {
            await repo.delete(t.id);
            load();
          },
          onAdd: () => _showAddSheet(context),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final c = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text("New Task"),
        message: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: c,
              placeholder: "Task title",
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.square_list),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              final title = c.text.trim();
              if (title.isEmpty) {
                showRootSnack("Task title cannot be empty");
                return;
              }
              await repo.create(title);
              Navigator.pop(context);
              load();
            },
            child: const Text("Save"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: const Text("Cancel"),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List tasks;
  final void Function(dynamic t) onToggle;
  final void Function(dynamic t) onEdit;
  final void Function(dynamic t) onDelete;
  final VoidCallback onAdd;

  const _TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: tasks.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: CupertinoColors.systemGrey4),
            itemBuilder: (_, i) {
              final t = tasks[i];
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onDelete(t),
                background: Container(
                  color: CupertinoColors.systemRed,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(CupertinoIcons.delete_solid,
                      color: CupertinoColors.white),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGroupedBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onToggle(t),
                        child: Icon(
                          t.done
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.circle,
                          color: t.done
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.inactiveGray,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label,
                            decoration: t.done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => onEdit(t),
                        child: const Icon(CupertinoIcons.pencil),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: CupertinoButton.filled(
            onPressed: onAdd,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.plus),
                SizedBox(width: 8),
                Text("Add Task"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.list_bullet, size: 64, color: CupertinoColors.systemGrey),
          const SizedBox(height: 12),
          const Text("No tasks yet",
              style: TextStyle(
                fontSize: 20,
                color: CupertinoColors.systemRed,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          const Text("Tap Add to create your first task",
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                decoration: TextDecoration.underline,
               decorationColor: CupertinoColors.systemYellow,
              )),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: onAdd,
            child: const Text("Add Task"),
          )
        ],
      ),
    );
  }
}

