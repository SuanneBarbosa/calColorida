import 'package:flutter/material.dart';

class ResultDisplay extends StatefulWidget {
  final String display;
  final int? currentNoteIndex;
  final Map<String, Color> digitColors;
  final String operation;

  const ResultDisplay({
    Key? key,
    required this.display,
    required this.operation,
    this.currentNoteIndex,
    required this.digitColors,
  }) : super(key: key);

  @override
  _ResultDisplayState createState() => _ResultDisplayState();
}

class _ResultDisplayState extends State<ResultDisplay> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(ResultDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentNoteIndex != null &&
        widget.currentNoteIndex != oldWidget.currentNoteIndex) {
      _scrollToCurrentDigit();
    }
  }

  void _scrollToCurrentDigit() {
    int decimalStartIndex = widget.display.indexOf('.') + 1;
    if (decimalStartIndex == 0) {
      return;
    }

    int actualIndex = decimalStartIndex + widget.currentNoteIndex!;
    double offset = (actualIndex - decimalStartIndex) * 20.0;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double displayHeight = 80.0;
    const double displayWidth = double.infinity;

    int decimalStartIndex = widget.display.indexOf('.') + 1;

    return Container(
      height: displayHeight,
      width: displayWidth,
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.blue[50], 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.display.split('').asMap().entries.map((entry) {
            final int index = entry.key;
            final String digit = entry.value;
            bool isDecimal = decimalStartIndex > 0 && index >= decimalStartIndex;
            bool isCurrentDigit =
                isDecimal && widget.currentNoteIndex != null && (index - decimalStartIndex) == widget.currentNoteIndex;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: isCurrentDigit
                    ? widget.digitColors[digit] ?? Colors.transparent
                    : Colors.transparent,
              ),
              child: Text(
                digit,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDecimal ? Colors.black : Colors.black54, 
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
