import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _workDuration = 25 * 60; // 25 minutes in seconds
  static const int _breakDuration = 5 * 60; // 5 minutes in seconds

  late int _timeRemaining;
  late Timer _timer;
  bool _isTimerRunning = false;
  bool _isWorkSession = true;

  @override
  void initState() {
    super.initState();
    _timeRemaining = _workDuration;
  }

  @override
  void dispose() {
    if (_isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    if (_isTimerRunning) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer.cancel();
          _isWorkSession = !_isWorkSession;
          _timeRemaining = _isWorkSession ? _workDuration : _breakDuration;
          _isTimerRunning = false;
          // Optionally, play a sound or show a notification
        }
      });
    });

    setState(() {
      _isTimerRunning = true;
    });
  }

  void _pauseTimer() {
    if (!_isTimerRunning) return;
    _timer.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _isWorkSession = true;
      _timeRemaining = _workDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isWorkSession ? 'Work' : 'Break',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: _isWorkSession ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isTimerRunning)
                  ElevatedButton(
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Start',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Pause',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Reset',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
