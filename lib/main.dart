import 'package:flutter/material.dart';
import 'app.dart';
import 'db.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DB.instance.init();
  runApp(const MyApp());
}