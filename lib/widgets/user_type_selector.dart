import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


enum eventType { current, past }

class SingleChoice extends StatefulWidget {
  final eventType initialSelection;
  final ValueChanged<eventType> onSelectionChanged;

  SingleChoice({
    required this.initialSelection,
    required this.onSelectionChanged,
  });

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  late eventType selectedevent;

  @override
  void initState() {
    super.initState();
    selectedevent = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<eventType>(
      segments: const <ButtonSegment<eventType>>[
        ButtonSegment<eventType>(
          value: eventType.current,
          label: const Text("Current"),
        ),
        ButtonSegment<eventType>(
          value: eventType.past,
          label: Text("Past"),
        ),
      ],
      selected: <eventType>{selectedevent},
      onSelectionChanged: (Set<eventType> newSelection) {
        setState(() {
          selectedevent = newSelection.first;
          widget.onSelectionChanged(selectedevent);
        });
      },
    );
  }
}


// class UserTypeSelector extends StatefulWidget {
//   final ValueChanged<String> onChanged;

//   UserTypeSelector({required this.onChanged});

//   @override
//   _UserTypeSelectorState createState() => _UserTypeSelectorState();
// }

// class _UserTypeSelectorState extends State<UserTypeSelector> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF6A2186), // Change the background color as needed
//         borderRadius: BorderRadius.circular(8.0), // Apply border radius
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: CupertinoSlidingSegmentedControl<int>(
//           groupValue: _selectedIndex,
//           children: {
//             0: Text("Sponsor"),
//             1: Text("Sponsee"),
//           },
//           onValueChanged: (value) {
//             setState(() {
//               _selectedIndex = value!;
//               widget.onChanged(value == 0 ? "Sponsor" : "Sponsee");
//             });
//           },
//         ),
//       ),
//     );
//   }
// }
