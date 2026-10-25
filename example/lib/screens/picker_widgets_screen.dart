import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({super.key});

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  DateTime? _date = DateTime(2026, 10, 22);
  DateTime? _empty;
  DateTime? _limited = DateTime(2026, 10, 18);
  DateTime? _rtl = DateTime(2026, 10, 22);

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkDatePicker',
    children: [
      const DemoHeading('Editable and controlled'),
      WelkDatePicker(
        label: 'Pick your adventure date',
        initialDisplayDate: DateTime(2026, 10, 24),
        value: _date,
        onChanged: (value) => setState(() => _date = value),
      ),
      Text('Selected: ${_date?.toIso8601String().split('T').first ?? 'none'}'),
      const DemoHeading('Empty · required'),
      WelkDatePicker(
        label: 'Departure date',
        value: _empty,
        initialDisplayDate: DateTime(2026, 10, 24),
        isRequired: true,
        onChanged: (value) => setState(() => _empty = value),
      ),
      const DemoHeading('Limited range · October 10–28'),
      WelkDatePicker(
        label: 'Available dates',
        initialDisplayDate: DateTime(2026, 10, 24),
        value: _limited,
        minDate: DateTime(2026, 10, 10),
        maxDate: DateTime(2026, 10, 28),
        onChanged: (value) => setState(() => _limited = value),
      ),
      const DemoHeading('Disabled'),
      WelkDatePicker(label: 'Not available', value: DateTime(2026, 10, 22)),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkDatePicker(
          label: 'Adventure date · RTL',
          initialDisplayDate: DateTime(2026, 10, 24),
          value: _rtl,
          onChanged: (value) => setState(() => _rtl = value),
        ),
      ),
    ],
  );
}

class DateInputScreen extends StatefulWidget {
  const DateInputScreen({super.key});

  @override
  State<DateInputScreen> createState() => _DateInputScreenState();
}

class _DateInputScreenState extends State<DateInputScreen> {
  DateTime? _date = DateTime(2026, 10, 22);
  DateTime? _empty;
  DateTime? _limited = DateTime(2026, 10, 18);
  DateTime? _validated;
  DateTime? _rtl = DateTime(2026, 10, 22);

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkDateInput',
    children: [
      const DemoHeading('Editable field · custom calendar popup'),
      WelkDateInput(
        label: 'Adventure date',
        initialDisplayDate: DateTime(2026, 10, 24),
        value: _date,
        onChanged: (value) => setState(() => _date = value),
      ),
      Text('Selected: ${_date?.toIso8601String().split('T').first ?? 'none'}'),
      const DemoHeading('Empty · required'),
      WelkDateInput(
        label: 'Departure date',
        value: _empty,
        initialDisplayDate: DateTime(2026, 10, 24),
        isRequired: true,
        onChanged: (value) => setState(() => _empty = value),
      ),
      const DemoHeading('Limited range · October 10–28'),
      WelkDateInput(
        label: 'Available dates',
        initialDisplayDate: DateTime(2026, 10, 24),
        value: _limited,
        minDate: DateTime(2026, 10, 10),
        maxDate: DateTime(2026, 10, 28),
        onChanged: (value) => setState(() => _limited = value),
      ),
      const DemoHeading('Custom validation'),
      WelkDateInput(
        label: 'Weekday departure',
        value: _validated,
        initialDisplayDate: DateTime(2026, 10, 24),
        validator: (date) => date != null && date.weekday >= DateTime.saturday
            ? 'Choose a weekday for departure.'
            : null,
        onChanged: (value) => setState(() => _validated = value),
      ),
      const DemoHeading('Disabled'),
      WelkDateInput(label: 'Not available', value: DateTime(2026, 10, 22)),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkDateInput(
          label: 'Adventure date · RTL',
          initialDisplayDate: DateTime(2026, 10, 24),
          value: _rtl,
          onChanged: (value) => setState(() => _rtl = value),
        ),
      ),
    ],
  );
}

class TimePickerScreen extends StatefulWidget {
  const TimePickerScreen({super.key});

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  WelkTime? _time = const WelkTime(hour: 14, minute: 30);
  WelkTime? _seconds = const WelkTime(hour: 14, minute: 30, second: 15);
  WelkTime? _empty;
  WelkTime? _validated = const WelkTime(hour: 9, minute: 0);
  WelkTime? _rtl = const WelkTime(hour: 14, minute: 30);

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkTimePicker',
    children: [
      const DemoHeading('Editable · scroll or tap columns'),
      WelkTimePicker(
        label: 'Adventure time',
        value: _time,
        onChanged: (value) => setState(() => _time = value),
      ),
      Text('Selected: ${_time?.format() ?? 'none'}'),
      const DemoHeading('With real seconds'),
      WelkTimePicker(
        label: 'Precise departure',
        value: _seconds,
        showSeconds: true,
        onChanged: (value) => setState(() => _seconds = value),
      ),
      Text('Selected: ${_seconds?.format(showSeconds: true) ?? 'none'}'),
      const DemoHeading('Empty · required'),
      WelkTimePicker(
        label: 'Choose a time',
        value: _empty,
        isRequired: true,
        onChanged: (value) => setState(() => _empty = value),
      ),
      const DemoHeading('Custom validation · after 09:00'),
      WelkTimePicker(
        label: 'Office appointment',
        value: _validated,
        validator: (time) =>
            time != null && time.hour < 9 ? 'Choose 09:00 or later.' : null,
        onChanged: (value) => setState(() => _validated = value),
      ),
      const DemoHeading('Disabled'),
      const WelkTimePicker(
        label: 'Not available',
        value: WelkTime(hour: 14, minute: 30),
      ),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkTimePicker(
          label: 'Adventure time · RTL',
          value: _rtl,
          onChanged: (value) => setState(() => _rtl = value),
        ),
      ),
    ],
  );
}
