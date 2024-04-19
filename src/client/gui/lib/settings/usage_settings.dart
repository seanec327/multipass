import 'dart:async';

import 'package:basics/basics.dart';
import 'package:flutter/material.dart' hide Switch;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;

// import 'package:hotkey_manager/hotkey_manager.dart';

import '../providers.dart';
import '../switch.dart';

final primaryNameProvider = clientSettingProvider(primaryNameKey);
final passphraseProvider = daemonSettingProvider(passphraseKey);
final privilegedMountsProvider = daemonSettingProvider(privilegedMountsKey);

class UsageSettings extends ConsumerWidget {
  const UsageSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryName = ref.watch(primaryNameProvider);
    final hasPassphrase = ref.watch(passphraseProvider.select((value) {
      return value.valueOrNull.isNotNullOrBlank;
    }));
    final privilegedMounts = ref.watch(privilegedMountsProvider.select((value) {
      return value.valueOrNull?.toBoolOption.toNullable() ?? false;
    }));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Usage',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      PrimaryNameField(
        value: primaryName,
        onSave: (value) {
          ref.read(primaryNameProvider.notifier).set(value);
        },
      ),
      const SizedBox(height: 20),
      PassphraseField(
        hasPassphrase: hasPassphrase,
        onSave: (value) {
          ref.read(passphraseProvider.notifier).set(value);
        },
      ),
      const SizedBox(height: 20),
      Switch(
        label: 'Allow privileged mounts',
        value: privilegedMounts,
        trailingSwitch: true,
        size: 30,
        onChanged: (value) {
          ref.read(privilegedMountsProvider.notifier).set(value.toString());
        },
      ),
    ]);
  }
}

// class HotkeyField extends StatefulWidget {
//   final HotKey? initialHotkey;
//   final ValueChanged<HotKey?> onSave;
//
//   const HotkeyField({
//     super.key,
//     required this.initialHotkey,
//     required this.onSave,
//   });
//
//   @override
//   State<HotkeyField> createState() => _HotkeyFieldState();
// }

// class _HotkeyFieldState extends State<HotkeyField> {
//   late var hotkey = widget.initialHotkey;
//   var changed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SettingField(
//       icon: 'assets/primary_instance.svg',
//       label: 'Primary instance name',
//       onSave: () => widget.onSave(hotkey),
//       onDiscard: () => hotkey = widget.initialHotkey,
//       changed: changed,
//       child: GestureDetector(),
//     );
//   }
// }

class PrimaryNameField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onSave;

  const PrimaryNameField({
    super.key,
    required this.value,
    required this.onSave,
  });

  @override
  State<PrimaryNameField> createState() => _PrimaryNameFieldState();
}

class _PrimaryNameFieldState extends State<PrimaryNameField> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormFieldState<String>>();
  var changed = false;

  @override
  void initState() {
    super.initState();
    controller.text = widget.value;
    controller.addListener(
      () => setState(() => changed = widget.value != controller.text),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PrimaryNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.text = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SettingField(
      label: 'Primary instance name',
      onSave: () {
        if (formKey.currentState!.validate()) widget.onSave(controller.text);
      },
      onDiscard: () {
        controller.text = widget.value;
        formKey.currentState!.validate();
      },
      changed: changed,
      child: TextFormField(
        key: formKey,
        controller: controller,
        validator: (value) {
          value ??= '';
          if (value.isEmpty) return null;
          if (RegExp(r'^[^A-Za-z]').hasMatch(value)) {
            return 'Name must start with a letter';
          }
          if (value.length < 2) return 'Name must be at least 2 characters';
          if (value.endsWith('-')) return 'Name must end in digit or letter';
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[-A-Za-z0-9]'))
        ],
      ),
    );
  }
}

class PassphraseField extends StatefulWidget {
  final bool hasPassphrase;
  final ValueChanged<String> onSave;

  const PassphraseField({
    super.key,
    required this.hasPassphrase,
    required this.onSave,
  });

  @override
  State<PassphraseField> createState() => _PassphraseFieldState();
}

class _PassphraseFieldState extends State<PassphraseField> {
  final controller = TextEditingController();
  final focus = FocusNode();
  var changed = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(hasChanged);
    focus.addListener(hasChanged);
  }

  void hasChanged() {
    Timer(100.milliseconds, () {
      setState(() {
        changed = (focus.hasFocus && widget.hasPassphrase) ||
            controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingField(
      label: 'Authentication passphrase',
      onSave: () => widget.onSave(controller.text),
      onDiscard: () => controller.text = '',
      changed: changed,
      child: TextField(
        controller: controller,
        focusNode: focus,
        obscureText: true,
      ),
    );
  }
}

class SettingField extends StatelessWidget {
  final String label;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final bool changed;
  final Widget child;

  const SettingField({
    super.key,
    required this.label,
    required this.onSave,
    required this.onDiscard,
    required this.changed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
      const SizedBox(width: 12),
      if (changed) ...[
        OutlinedButton(
          onPressed: onSave,
          child: const Icon(Icons.check, color: Color(0xff0E8620)),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onDiscard,
          child: const Icon(Icons.close, color: Color(0xffC7162B)),
        ),
        const SizedBox(width: 12),
      ],
      SizedBox(width: 260, child: child),
    ]);
  }
}
