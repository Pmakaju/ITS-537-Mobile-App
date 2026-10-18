import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const GestureLabApp());

class GestureLabApp extends StatelessWidget {
  const GestureLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GestureHome(),
    );
  }
}

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

  // Gesture 1: tap changes the color and counts taps
  void _onTap() {
    setState(() {
      _tapCount++;
      _colorIndex = (_colorIndex + 1) % _colors.length;
      _message = 'Tapped $_tapCount time${_tapCount == 1 ? '' : 's'}';
    });
  }

  // Gesture 2: long press resets the box
  // Refinement: added haptic feedback so the user can feel the reset
  void _onLongPress() {
    HapticFeedback.mediumImpact();
    setState(() {
      _tapCount = 0;
      _colorIndex = 0;
      _message = 'Reset! Tap me again';
    });
  }

  // Gesture 3: swipe removes an item
  // Refinement: added an Undo option in case of an accidental swipe
  void _onDismissed(int index) {
    final removed = _items[index];
    setState(() => _items.removeAt(index));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$removed"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _items.insert(index, removed)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture Lab')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 240,
              height: 160,
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
          const SizedBox(height: 8),
          const Text('Tap = change color   |   Long press = reset'),
          const SizedBox(height: 24),
          const Text(
            'Swipe an item left or right to remove it',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('All done!'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Dismissible(
                        key: ValueKey(item),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _onDismissed(index),
                        child: ListTile(
                          title: Text(item),
                          leading: const Icon(Icons.check_circle_outline),
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
