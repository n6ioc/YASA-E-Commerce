import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _profileEnsured = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileEnsured) return;
    final auth = context.read<AuthController>();
    if (auth.isSignedIn) {
      _profileEnsured = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pc = context.read<ProfileController>();
        pc.ensureForUser(uid: auth.user!.uid, email: auth.user!.email);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final auth = context.watch<AuthController>();
    final pc = context.watch<ProfileController>();
    final colors = const [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.pink, Colors.green, Colors.blueGrey];

    if (pc.profile != null) {
      final p = pc.profile!;
      if (_name.text != p.name) _name.text = p.name;
      if (_address.text != p.address) _address.text = p.address;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(auth.isSignedIn ? (pc.profile?.name.isNotEmpty == true ? pc.profile!.name : (auth.user?.email ?? 'Guest')) : 'Not signed in'),
          subtitle: Text(auth.isSignedIn ? 'UID: ${auth.user!.uid}' : 'Tap to sign in'),
          onTap: () => context.go('/signin'),
        ),
        if (auth.isSignedIn) ...[
          const SizedBox(height: 8),
          Text('Profile', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) {
                  final x = (v ?? '').trim();
                  if (x.isEmpty) return 'Name is required';
                  if (x.length < 3) return 'Enter your full name';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) {
                  final x = (v ?? '').trim();
                  if (x.isEmpty) return 'Address is required';
                  if (x.length < 6) return 'Enter a valid address';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: pc.loading ? null : () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    pc.setName(_name.text.trim());
                    pc.setAddress(_address.text.trim());
                    await pc.save();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
                  },
                  icon: pc.loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ]),
          ),
          const Divider(height: 32),
        ],
        const Divider(),
        SwitchListTile(
          value: s.prefs.themeMode == ThemeMode.dark,
          onChanged: (v) => s.setDark(v),
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark themes'),
        ),
        const SizedBox(height: 8),
        const Text('Seed Color'),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (int i = 0; i < colors.length; i++)
              ChoiceChip(
                label: Text('#${i + 1}'),
                selected: s.prefs.seedColorIndex == i,
                onSelected: (_) => s.setSeedIndex(i),
                avatar: CircleAvatar(backgroundColor: colors[i]),
              ),
          ],
        ),
      ],
    );
  }
}