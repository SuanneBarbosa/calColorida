import 'package:flutter/material.dart';

class MosaicDisplay extends StatefulWidget {
  final String result;
  final Map<String, Color> digitColors;
  final int decimalPlaces;
  final int digitsPerRow;
  final double squareSize;
  final int? currentNoteIndex;
  final Function(int)? onNoteTap;
  final Function(int)? onMaxDigitsCalculated;

  const MosaicDisplay({
    super.key,
    required this.result,
    required this.digitColors,
    required this.decimalPlaces,
    required this.digitsPerRow,
    required this.squareSize,
    this.currentNoteIndex,
    this.onNoteTap,
    this.onMaxDigitsCalculated,
  });

  @override
  _MosaicDisplayState createState() => _MosaicDisplayState();
}

class _MosaicDisplayState extends State<MosaicDisplay> {
  int? _previousMaxDigits;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;
        int numRows = 14;
        double safeSquareSize =
            widget.squareSize <= 0 ? 1.0 : widget.squareSize;
        double safeAvailableHeight =
            (availableHeight.isFinite && !availableHeight.isNaN)
                ? availableHeight
                : 100.0; // um valor padrão qualquer que não seja zero

        double ratio = safeAvailableHeight / safeSquareSize;
        if (!ratio.isFinite || ratio.isNaN) {
          ratio = 1.0; // fallback
        }

        int maxRows = ratio.floor();
        // int maxRows = (availableHeight / widget.squareSize).floor();
        if (maxRows < numRows) {
          numRows = maxRows;
        }
        int digitsPerRow = widget.digitsPerRow;
        int maxDigits = digitsPerRow * numRows;
        if (_previousMaxDigits != maxDigits) {
          _previousMaxDigits = maxDigits;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.onMaxDigitsCalculated != null) {
              widget.onMaxDigitsCalculated!(maxDigits);
            }
          });
        }

        return _buildMosaic(widget.result, maxDigits, digitsPerRow);
      },
    );
  }

  Widget _buildMosaic(String result, int maxDigits, int digitsPerRow) {
    if (result.contains('.')) {
      String decimalPart = result.split('.')[1];
      decimalPart = decimalPart.replaceAll(RegExp(r'0+$'), '');

      if (decimalPart.length > maxDigits) {
        decimalPart = decimalPart.substring(0, maxDigits);
      }

      List<List<String>> decimalGroups = [];
      for (var i = 0; i < decimalPart.length; i += digitsPerRow) {
        int endIndex = i + digitsPerRow;
        if (endIndex > decimalPart.length) {
          endIndex = decimalPart.length;
        }
        decimalGroups.add(decimalPart.substring(i, endIndex).split(''));
      }

      List<Widget> mosaicRows = decimalGroups.asMap().entries.map((entry) {
        final int rowIndex = entry.key;
        final List<String> group = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: group.asMap().entries.map((entry) {
            final int digitIndex = entry.key;
            final String digit = entry.value;
            final int globalIndex = rowIndex * digitsPerRow + digitIndex;

            return GestureDetector(
              onTap: () {
                if (widget.onNoteTap != null) {
                  widget.onNoteTap!(globalIndex);
                }
              },
              child: Container(
                width: widget.squareSize,
                height: widget.squareSize,
                decoration: BoxDecoration(
                  color: widget.currentNoteIndex == globalIndex
                      ? Colors.black
                      : widget.digitColors[digit],
                  border: Border.all(color: Colors.black, width: 1),
                ),
              ),
            );
          }).toList(),
        );
      }).toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: mosaicRows,
        ),
      );
    } else {
      return Container();
    }
  }
}
