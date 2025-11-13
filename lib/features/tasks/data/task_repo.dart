import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'task_model.dart';

class TaskRepo {
  final _class = "Task";

  Task _map(ParseObject o) => Task(
    id: o.objectId!,
    title: o.get<String>('title') ?? '',
    done: o.get<bool>('done') ?? false,
  );

  Future<List<Task>> list() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    final q = QueryBuilder(ParseObject(_class))..whereEqualTo("owner", user);
    final res = await q.query();
    return res.success && res.results != null
        ? res.results!.map((e) => _map(e)).toList()
        : [];
  }

  Future<void> create(String title) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    await (ParseObject(_class)
          ..set("title", title)
          ..set("done", false)
          ..set("owner", user))
        .save();
  }

  Future<void> toggle(Task t) async =>
      await (ParseObject(_class)
            ..objectId = t.id
            ..set("done", !t.done))
          .save();

  Future<void> delete(String id) async =>
      await (ParseObject(_class)..objectId = id).delete();

  Future<void> updateTitle(Task t, String newTitle) async =>
      await (ParseObject(_class)
            ..objectId = t.id
            ..set("title", newTitle))
          .save();
}
