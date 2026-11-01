
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const GestureLabApp());

class GestureLabApp extends StatelessWidget {
  const GestureLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture & Navigation Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GestureHome(),
    );
  }
}

// SCREEN 1: HOME
class GestureHome extends StatefulWidget {
  const GestureHome({super.key});

  @override
  State<GestureHome> createState() => _GestureHomeState();
}

class _GestureHomeState extends State<GestureHome> {
  final List<Color> _colors = [
    Colors.teal,
    Colors.orange,
    Colors.indigo,
    Colors.pink,
  ];

  int _colorIndex = 0;
  int _tapCount = 0;
  String _message = 'Tap me, or press and hold';

  final List<String> _items = [
    'Finish Chapter 5 reading',
    'Submit lab',
    'Reply to classmates',
    'Review for quiz',
  ];

  final Set<String> _completedTasks = {};

  // Gesture 1: Tap to change color
  void _onTap() {
    setState(() {
      _tapCount++;
      _colorIndex = (_colorIndex + 1) % _colors.length;
      _message =
          'Tapped $_tapCount time${_tapCount == 1 ? '' : 's'}';
    });
  }

  // Gesture 2: Long press to reset
  void _onLongPress() {
    HapticFeedback.mediumImpact();

    setState(() {
      _tapCount = 0;
      _colorIndex = 0;
      _message = 'Reset! Tap me again';
    });
  }

  // Gesture 3: Swipe to remove task
  void _onDismissed(String item, int index) {
    final wasCompleted = _completedTasks.contains(item);

    setState(() {
      _items.remove(item);
      _completedTasks.remove(item);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$item"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              final position = index.clamp(0, _items.length);
              _items.insert(position, item);

              if (wasCompleted) {
                _completedTasks.add(item);
              }
            });
          },
        ),
      ),
    );
  }

  // Navigate to Screen 2 and receive completion result
  Future<void> _openTaskDetails(String task) async {
    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );

    if (!mounted) return;

    if (completed == true) {
      setState(() {
        _completedTasks.add(task);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Completed: $task'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture & Navigation Lab'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Existing gesture box
          GestureDetector(
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 240,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _colors[_colorIndex],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Tap = change color | Long press = reset',
            style: TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tap a task to view details.\n'
              'Swipe left or right to remove it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Task list
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('All done!'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final completed =
                          _completedTasks.contains(item);

                      return Dismissible(
                        key: ValueKey(item),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            _onDismissed(item, index),
                        child: ListTile(
                          leading: Icon(
                            completed
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: completed
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(
                            item,
                            style: TextStyle(
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            completed
                                ? 'Completed'
                                : 'Tap to view details',
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios),
                          onTap: () => _openTaskDetails(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// SCREEN 2: TASK DETAILS
class TaskDetailsScreen extends StatelessWidget {
  final String task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  // Navigate to Screen 3 and receive result
  Future<void> _openSummary(BuildContext context) async {
    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskSummaryScreen(task: task),
      ),
    );

    if (!context.mounted) return;

    // Pass completion result back to Home
    if (completed == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.assignment,
                size: 70,
                color: Colors.teal,
              ),

              const SizedBox(height: 20),

              const Text(
                'Selected Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                task,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
              ),

              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: () => _openSummary(context),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Task Summary'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SCREEN 3: TASK SUMMARY
class TaskSummaryScreen extends StatelessWidget {
  final String task;

  const TaskSummaryScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Summary'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fact_check,
                size: 70,
                color: Colors.teal,
              ),

              const SizedBox(height: 20),

              const Text(
                'Task Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                task,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 12),

              const Text(
                'Are you ready to mark this task as complete?',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              FilledButton.icon(
                onPressed: () {
                  // Return true to Task Details
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.check),
                label: const Text('Mark as Complete'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
