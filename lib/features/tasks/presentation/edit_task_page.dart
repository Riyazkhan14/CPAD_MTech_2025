import 'package:flutter/material.dart';
import '../data/task_repo.dart';
import '../data/task_model.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final TextEditingController c;

  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.task.title);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }
  bool saving = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: c,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (c.text.trim().isEmpty) {
                  ScaffoldMessenger.of(
                    Navigator.of(context).overlay!.context,
                  ).showSnackBar(
                    const SnackBar(content: Text("Task title cannot be empty")),
                  );
                  return;
                }
                setState(() => saving = true);
                await TaskRepo().updateTitle(widget.task, c.text.trim());
                if (!mounted) return;
                Navigator.pop(context);
                setState(() => saving = false);
              },
              child: saving
                  ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
