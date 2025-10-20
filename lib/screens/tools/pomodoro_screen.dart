import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late int _workDuration;
  late int _breakDuration;

  late int _timeRemaining;
  late Timer _timer;
  bool _isTimerRunning = false;
  bool _isWorkSession = true;

  @override
  void initState() {
    super.initState();
    _workDuration = 25 * 60; // Default to 25 minutes
    _breakDuration = 5 * 60; // Default to 5 minutes
    _timeRemaining = _workDuration;
    _loadSettings();
  }

  @override
  void dispose() {
    if (_isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workDuration = (prefs.getInt('workDuration') ?? 25) * 60;
      _breakDuration = (prefs.getInt('breakDuration') ?? 5) * 60;
      if (!_isTimerRunning) {
        _timeRemaining = _isWorkSession ? _workDuration : _breakDuration;
      }
    });
  }

  Future<void> _updateDuration(bool isWork, bool increment) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (isWork) {
        int currentMinutes = _workDuration ~/ 60;
        if (increment) {
          currentMinutes++;
        } else if (currentMinutes > 1) {
          currentMinutes--;
        }
        _workDuration = currentMinutes * 60;
        prefs.setInt('workDuration', currentMinutes);
      } else {
        int currentMinutes = _breakDuration ~/ 60;
        if (increment) {
          currentMinutes++;
        } else if (currentMinutes > 1) {
          currentMinutes--;
        }
        _breakDuration = currentMinutes * 60;
        prefs.setInt('breakDuration', currentMinutes);
      }
      _resetTimer();
    });
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
    final int totalDuration = (_isWorkSession ? _workDuration : _breakDuration)
        .clamp(1, 86400);
    final double progress = _timeRemaining / totalDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pomodoro Timer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.red.shade700,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isWorkSession
                                  ? Colors.red.shade400
                                  : Colors.green.shade400,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formattedTime,
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isWorkSession ? 'WORK' : 'BREAK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isTimerRunning)
                        _buildControlButton(
                          onPressed: _startTimer,
                          icon: Icons.play_arrow,
                          label: 'START',
                          color: Colors.white,
                          backgroundColor: Colors.red.shade400,
                        )
                      else
                        _buildControlButton(
                          onPressed: _pauseTimer,
                          icon: Icons.pause,
                          label: 'PAUSE',
                          color: Colors.white,
                          backgroundColor: Colors.orange.shade400,
                        ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        onPressed: _resetTimer,
                        icon: Icons.replay,
                        label: 'RESET',
                        color: Colors.grey[800]!,
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDurationEditor(
                        label: 'Work',
                        duration: _workDuration,
                        onIncrement: () => _updateDuration(true, true),
                        onDecrement: () => _updateDuration(true, false),
                      ),
                      const SizedBox(height: 16),
                      _buildDurationEditor(
                        label: 'Break',
                        duration: _breakDuration,
                        onIncrement: () => _updateDuration(false, true),
                        onDecrement: () => _updateDuration(false, false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  Widget _buildDurationEditor({
    required String label,
    required int duration,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrement,
              iconSize: 28,
              color: Colors.grey[400],
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${duration ~/ 60}m',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrement,
              iconSize: 28,
              color: Colors.red.shade400,
            ),
          ],
        ),
      ],
    );
  }
}
