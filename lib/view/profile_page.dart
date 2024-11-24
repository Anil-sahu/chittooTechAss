import 'package:chittootech/view/question.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuestionPage()),
          );
        },
        child: const Text("Win Certificate"),
      ),
    );
  }
}
