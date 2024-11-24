import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  late Timer _timer;
  int _secondsRemaining = 30;
  bool _isEditable = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _isEditable = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Win Certificate")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Tell me About Yourself?",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              enabled: _isEditable,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type your answer here...",
              ),
            ),
            const SizedBox(height: 16),
            Text("Time remaining: $_secondsRemaining seconds"),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  side: const BorderSide(width: 1, color: Colors.white)),
              onPressed: !_isEditable
                  ? () {
                      Fluttertoast.showToast(
                          msg: "Your answer has been submitted");
                    }
                  : null,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
