import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//EditScheduleView

class EditScheduleView extends StatefulWidget {
  EditScheduleView({super.key});

  @override
  State<EditScheduleView> createState() => _EditScheduleViewState();
}

class _EditScheduleViewState extends State<EditScheduleView> {
  final textController = TextEditingController();

  final scrollController = ScrollController();
  final double _spacer = 20;

  TimeOfDay _timeOfDay = TimeOfDay.now();

  _timePick() async {
    _timeOfDay = await showTimePicker(
          initialTime: _timeOfDay,
          context: context,
        ) ??
        TimeOfDay.now();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0, 32, 8),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text('Edit schedule ' + MediaQuery.of(context).size.width.toString(),
            textScaleFactor: 1.8,
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: _spacer),
        TextField(
          maxLength: 533,
          minLines: 3,
          maxLines: 30,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            hintText:
                'type or copy a prayer in to this box (long-press to paste)',
            hintStyle:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
          ),
          controller: textController,
          scrollController: scrollController,
        ),
        SizedBox(height: _spacer),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              GestureDetector(
                  child: Text(
                    'time: ' + _timeOfDay.format(context),
                    textScaleFactor: 2,
                  ),
                  onTap: _timePick),
              IconButton(icon: Icon(Icons.edit), onPressed: _timePick)
            ],
          ),
        ),
        SizedBox(height: _spacer),
        Wrap(
            direction: Axis.horizontal,
            children: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
                .map((e) => FittedBox(
                      fit: BoxFit.scaleDown, //color: Colors.red,
                      child: CheckboxMenuButton(
                          value: true, onChanged: (v) {}, child: Text(e)),
                    ))
                .toList()),
        SizedBox(height: _spacer),
        Expanded(child: Container()),
      ]),
    );
  }
}
