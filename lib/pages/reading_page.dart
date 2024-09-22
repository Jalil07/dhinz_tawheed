import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingPage extends StatefulWidget {
  final String title;
  final String content;

  ReadingPage({required this.title, required this.content});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  // Load saved font size from SharedPreferences
  Future<void> _loadFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;  // Default font size is 16.0
    });
  }

  // Save font size to SharedPreferences
  Future<void> _saveFontSize(double fontSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', fontSize);
  }

  // Copy title and content to clipboard
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: "${widget.title}\n\n${widget.content}"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  // Show bottom sheet with slider to adjust font size
  void _showFontSizeAdjuster(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        double localFontSize = _fontSize;  // Create a local variable for font size

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Adjust Font Size',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: localFontSize,
                    min: 12.0,
                    max: 30.0,
                    divisions: 18,
                    label: localFontSize.toString(),
                    onChanged: (double value) {
                      setModalState(() {
                        localFontSize = value;  // Update local state for the slider
                      });
                      setState(() {
                        _fontSize = value;  // Update the main state for the font size
                      });
                    },
                    onChangeEnd: (double value) {
                      _saveFontSize(value);  // Save the font size after adjustment
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              _copyToClipboard(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              _showFontSizeAdjuster(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                widget.content,
                style: TextStyle(fontSize: _fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
