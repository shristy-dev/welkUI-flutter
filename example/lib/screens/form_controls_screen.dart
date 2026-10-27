import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class CheckBoxScreen extends StatefulWidget {
  const CheckBoxScreen({super.key});
  @override
  State<CheckBoxScreen> createState() => _CheckBoxScreenState();
}

class _CheckBoxScreenState extends State<CheckBoxScreen> {
  bool _included = false;
  bool _checked = true;
  bool _mixed = true;
  bool _rtl = false;

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkCheckBox',
    children: [
      const DemoHeading('Default and checked'),
      WelkCheckBox(
        label: 'Count me in',
        value: _included,
        onChanged: (v) => setState(() => _included = v),
      ),
      WelkCheckBox(
        label: 'Send me hero updates',
        value: _checked,
        onChanged: (v) => setState(() => _checked = v),
      ),
      const DemoHeading('Mixed selection'),
      WelkCheckBox(
        label: 'Select the whole team',
        value: _mixed,
        indeterminate: _mixed,
        onChanged: (_) => setState(() => _mixed = !_mixed),
      ),
      const DemoHeading('Disabled'),
      const WelkCheckBox(label: 'Unavailable', value: false),
      const WelkCheckBox(label: 'Already included', value: true),
      const DemoHeading('Right to left and wrapping'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkCheckBox(
          label: 'Receive helpful updates about the workspace and its members',
          value: _rtl,
          onChanged: (v) => setState(() => _rtl = v),
        ),
      ),
    ],
  );
}

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});
  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  String? _role;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkRadio',
    children: [
      const DemoHeading('Choose a role'),
      for (final role in ['Hero', 'Sidekick'])
        WelkRadio(
          label: role,
          selected: _role == role,
          onChanged: (_) => setState(() => _role = role),
        ),
      Text('Selected: ${_role ?? 'none'}'),
      const DemoHeading('Disabled'),
      const WelkRadio(label: 'Unavailable', selected: false),
      const WelkRadio(label: 'Reserved role', selected: true),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkRadio(
          label: 'Be a hero',
          selected: _role == 'Hero',
          onChanged: (_) => setState(() => _role = 'Hero'),
        ),
      ),
    ],
  );
}

const _roles = [
  WelkRadioOption(value: 'hero', label: 'Hero'),
  WelkRadioOption(value: 'sidekick', label: 'Sidekick'),
  WelkRadioOption(value: 'villain', label: 'Villain', disabled: true),
];

class RadioGroupScreen extends StatefulWidget {
  const RadioGroupScreen({super.key});
  @override
  State<RadioGroupScreen> createState() => _RadioGroupScreenState();
}

class _RadioGroupScreenState extends State<RadioGroupScreen> {
  String? _default;
  String? _required = 'hero';
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkRadioGroup',
    children: [
      const DemoHeading('Choose your role'),
      WelkRadioGroup(
        label: 'Your team',
        options: _roles,
        value: _default,
        onChanged: (v) => setState(() => _default = v),
      ),
      Text('Selected: ${_default ?? 'none'}'),
      const DemoHeading('Required and preselected'),
      WelkRadioGroup(
        label: 'Mission role',
        options: _roles,
        isRequired: true,
        value: _required,
        onChanged: (v) => setState(() => _required = v),
      ),
      const DemoHeading('Disabled group'),
      const WelkRadioGroup(
        label: 'Reserved team',
        options: _roles,
        value: 'hero',
        disabled: true,
      ),
    ],
  );
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String _name = '';
  String _secret = '';
  String _email = 'not-an-email';
  String _query = '';
  String _tel = '';
  String _url = '';

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkInput',
    children: [
      const DemoHeading('Your name'),
      WelkInput(
        label: 'Hero name',
        placeholder: 'A comic book hero…',
        value: _name,
        onChanged: (v) => setState(() => _name = v),
        endAction: WelkInputAction(
          icon: const Icon(Icons.close, size: 24),
          label: 'Clear name',
          onPressed: () => setState(() => _name = ''),
        ),
      ),
      const DemoHeading('Password'),
      WelkInput(
        label: 'Secret identity',
        type: WelkInputType.password,
        value: _secret,
        onChanged: (v) => setState(() => _secret = v),
      ),
      const DemoHeading('Validation'),
      WelkInput(
        label: 'Email address',
        type: WelkInputType.email,
        value: _email,
        isRequired: true,
        invalid: !_email.contains('@'),
        errorText: _email.contains('@') ? null : 'Please enter a valid email.',
        onChanged: (v) => setState(() => _email = v),
      ),
      const DemoHeading('Search, telephone and URL'),
      WelkInput(
        label: 'Search heroes',
        type: WelkInputType.search,
        value: _query,
        onChanged: (v) => setState(() => _query = v),
      ),
      const SizedBox(height: 16),
      WelkInput(
        label: 'Telephone',
        type: WelkInputType.tel,
        value: _tel,
        onChanged: (v) => setState(() => _tel = v),
      ),
      const SizedBox(height: 16),
      WelkInput(
        label: 'Website',
        type: WelkInputType.url,
        value: _url,
        onChanged: (v) => setState(() => _url = v),
      ),
      const DemoHeading('Read only and disabled'),
      const WelkInput(
        label: 'Your identity',
        value: 'Captain Welk',
        readOnly: true,
      ),
      const SizedBox(height: 16),
      const WelkInput(label: 'Unavailable', value: '', disabled: true),
    ],
  );
}

class OTPInputScreen extends StatefulWidget {
  const OTPInputScreen({super.key});
  @override
  State<OTPInputScreen> createState() => _OTPInputScreenState();
}

class _OTPInputScreenState extends State<OTPInputScreen> {
  String _code = '';
  String _short = '';
  String? _completed;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkOTPInput',
    children: [
      const DemoHeading('Verification code'),
      WelkOTPInput(
        label: 'Six-digit code',
        value: _code,
        onChanged: (v) => setState(() => _code = v),
        onComplete: (v) => setState(() => _completed = v),
      ),
      if (_completed != null) Text('Completed: $_completed'),
      const DemoHeading('Four digits'),
      WelkOTPInput(
        label: 'Access PIN',
        length: 4,
        value: _short,
        onChanged: (v) => setState(() => _short = v),
      ),
      const DemoHeading('Disabled and invalid'),
      const WelkOTPInput(label: 'Unavailable', value: '123', disabled: true),
      const SizedBox(height: 20),
      const WelkOTPInput(
        label: 'Expired code',
        value: '123456',
        invalid: true,
        readOnly: true,
      ),
    ],
  );
}

const _heroes = [
  WelkDropDownOption(value: 'superman', label: 'Superman'),
  WelkDropDownOption(value: 'batman', label: 'Batman'),
  WelkDropDownOption(value: 'wonder-woman', label: 'Wonder Woman'),
  WelkDropDownOption(value: 'flash', label: 'Flash', disabled: true),
];

class DropDownScreen extends StatefulWidget {
  const DropDownScreen({super.key});
  @override
  State<DropDownScreen> createState() => _DropDownScreenState();
}

class _DropDownScreenState extends State<DropDownScreen> {
  String? _hero;
  String? _search = 'batman';
  String? _required;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkDropDown',
    children: [
      const DemoHeading('Choose your hero'),
      WelkDropDown(
        label: 'Hero',
        options: _heroes,
        value: _hero,
        onChanged: (v) => setState(() => _hero = v),
      ),
      SizedBox(height: 20),
      Text('Selected: ${_hero ?? 'none'}'),
      const DemoHeading('Searchable and preselected'),
      WelkDropDown(
        label: 'Search heroes',
        options: _heroes,
        value: _search,
        searchable: true,
        onChanged: (v) => setState(() => _search = v),
      ),
      const DemoHeading('Required, right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkDropDown(
          label: 'Mission leader',
          options: _heroes,
          value: _required,
          isRequired: true,
          onChanged: (v) => setState(() => _required = v),
        ),
      ),
      const DemoHeading('Disabled'),
      const WelkDropDown(
        label: 'Reserved hero',
        options: _heroes,
        value: 'batman',
        disabled: true,
      ),
    ],
  );
}

class RangeSliderScreen extends StatefulWidget {
  const RangeSliderScreen({super.key});
  @override
  State<RangeSliderScreen> createState() => _RangeSliderScreenState();
}

class _RangeSliderScreenState extends State<RangeSliderScreen> {
  double _power = 50;
  double _step = 4;
  double _rtl = 25;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkRangeSlider',
    children: [
      const DemoHeading('Hero power'),
      WelkRangeSlider(
        label: 'Hero power: ${_power.toInt()}',
        value: _power,
        onChanged: (v) => setState(() => _power = v),
      ),
      const DemoHeading('Stepped'),
      WelkRangeSlider(
        label: 'Level: ${_step.toInt()}',
        value: _step,
        min: 0,
        max: 10,
        step: 2,
        onChanged: (v) => setState(() => _step = v),
      ),
      const DemoHeading('Disabled'),
      const WelkRangeSlider(label: 'Reserved power', value: 50),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkRangeSlider(
          label: 'Power: ${_rtl.toInt()}',
          value: _rtl,
          onChanged: (v) => setState(() => _rtl = v),
        ),
      ),
    ],
  );
}
