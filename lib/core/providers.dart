import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

final currentUserProvider = FutureProvider((ref) async {
  return await ParseUser.currentUser() as ParseUser?;
});
