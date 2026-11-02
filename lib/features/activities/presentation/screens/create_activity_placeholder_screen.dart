import 'package:flutter/material.dart';

class CreateActivityPlaceholderScreen extends StatelessWidget {
  const CreateActivityPlaceholderScreen({super.key});

  static const routeName = '/create-activity';
  static const screenKey = Key('create_activity_placeholder');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Первое занятие',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text('На следующем шаге здесь появится простая форма.'),
            ],
          ),
        ),
      ),
    );
  }
}
