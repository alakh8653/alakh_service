
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  FlutterError.onError = AdminErrorHandler.handleFlutterError;
  runApp(const AdminApp());

void main() {
  // TODO: Implement entry point

}
