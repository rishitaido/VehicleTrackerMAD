import 'package:flutter/material.dart';

class RemindersScreen extends StatefulWidget{
  @override
  State<RemindersScreen> createState() => _RemindersScreenState(); 
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContextcontext){
    return Scaffold(
      appBar:AppBar(
        title: const Text('Reminders'), 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active,
              size: 100, 
              color: Colors.grey[400],
            ),

            const SizedBox(height: 24),
            Text(
              'Reminders',
              style: Theme.of(context).textTheme.headlineSmall,
              ),
          ],
        ),
      ),
    );
  }
}