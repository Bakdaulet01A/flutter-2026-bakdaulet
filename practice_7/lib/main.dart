import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _done = true;
      });
    }
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthController.clear();

      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Future<void> _pickBirthDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date == null) return;
    if (mounted == false) return;

    setState(() {
      _birth = date;

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      _birthController.text = '$day.$month.$year';
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }

    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: _done
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SummaryCard(
                    name: _name.text,
                    email: _email.text,
                    group: _group ?? '',
                    birthDate: _birthController.text,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _startOver,
                    child: const Text('Start over'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _emailFocus.requestFocus();
                      },
                      onTapOutside: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if ((value ?? '').trim().length < 2) {
                          return 'Name is too short';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _email,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onTapOutside: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'name@kbtu.kz',
                      ),
                      validator: (value) {
                        final email = (value ?? '').trim();
                        final at = email.indexOf('@');

                        if (at <= 0 || email.indexOf('.', at) == -1) {
                          return 'Email looks wrong';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        setState(() {});
                      },
                      onTapOutside: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'At least 8 characters',
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 8) {
                          return 'Password is too short';
                        }
                        return null;
                      },
                    ),
                    Text('${_password.text.length} of 8'),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: _agreed
                          ? (_) {
                              _signUp();
                            }
                          : null,
                      onTapOutside: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty || value != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _group,
                      decoration: const InputDecoration(labelText: 'Group'),
                      items: [
                        for (final group in groups)
                          DropdownMenuItem(value: group, child: Text(group)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _group = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Choose a group';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _birthController,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      onTapOutside: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Date of birth',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (_) {
                        if (_birth == null) {
                          return 'Choose a date';
                        }
                        return null;
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('I agree to the rules'),
                      value: _agreed,
                      onChanged: (value) {
                        setState(() {
                          _agreed = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _agreed ? _signUp : null,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
