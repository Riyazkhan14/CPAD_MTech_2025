import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<void> initParse() async {
  await Parse().initialize(
    dotenv.env['PARSE_APP_ID']!,
    dotenv.env['PARSE_SERVER_URL']!,
    clientKey: dotenv.env['PARSE_CLIENT_KEY'],
    autoSendSessionId: true,
  );
}
