import 'package:flutter/material.dart';

class PrioritySelectSection extends StatelessWidget {
  final GlobalKey<FormFieldState<String?>> fieldKey;
  final String? prefilled;
  const PrioritySelectSection({
    super.key,
    required this.fieldKey,
    this.prefilled
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String?>(
      key: fieldKey,
      initialValue: prefilled,
      validator: (value) {
        if (value == null) return "Please select a priority";
        return null;
      },
      builder: (FormFieldState<String?> state) {
        final priority = state.value;
        return Column(
          children: [
            Text("Priority"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                    children: [
                      IconButton(
                          onPressed: () => state.didChange("low"),
                          icon: Icon(Icons.flag, color: priority == "low" ? Colors.grey : Colors.black)
                      ),
                      Text("Low")
                    ]),
                Column(
                  children: [
                    IconButton(
                        onPressed: () => state.didChange("medium"),
                        icon: Icon(Icons.flag, color: priority == "medium" ? Colors.yellow : Colors.black)),
                    Text("Medium")
                  ],
                ),
                Column(
                    children: [
                      IconButton(
                          onPressed: () => state.didChange("high"),
                          icon: Icon(Icons.flag, color: priority == "high" ? Colors.red : Colors.black)),
                      Text("High")
                    ])
              ],
            ),
            if(state.hasError)
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("${state.errorText}"))
          ],
        );
      },
    );
  }
}