import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});
  @override State<SignInView> createState() => _SignInState();
}

class _SignInState extends State<SignInView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _signupMode = false;
  bool _obscure = true;

  @override void dispose() { _email.dispose(); _password.dispose(); _name.dispose(); _address.dispose(); super.dispose(); }

  bool _validate() => _form.currentState?.validate() ?? false;

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthController>();
    final email = _email.text.trim();
    final pass = _password.text;
    final err = _signupMode ? await auth.signUp(email, pass) : await auth.signIn(email, pass);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (err != null) _error = _friendlyAuthError(err);
    });
    if (err == null) {
      // On signup, persist user's name and address locally
      if (_signupMode) {
        final storage = context.read<StorageService>();
        await storage.saveUserData(email: email, name: _name.text.trim(), address: _address.text.trim());
      }
      context.pop();
    }
  }

  Future<void> _guest() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthController>();
    final err = await auth.signInAnonymously();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (err != null) _error = _friendlyAuthError(err);
    });
    if (err == null) context.pop();
  }

  Future<void> _resetPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _email.text.trim());
    final entered = await showDialog<String?>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, null), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, emailCtrl.text.trim()), child: const Text('Send')),
        ],
      ),
    );
    if (entered != null && entered.isNotEmpty) {
      final err = await context.read<AuthController>().resetPassword(entered);
      if (!mounted) return;
      final snack = err == null ? 'Password reset email sent' : _friendlyAuthError(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
    }
  }

  String _friendlyAuthError(String raw) {
    if (raw.contains('invalid-email')) return 'Invalid email address';
    if (raw.contains('user-not-found')) return 'No account found for this email';
    if (raw.contains('wrong-password')) return 'Incorrect password';
    if (raw.contains('email-already-in-use')) return 'Email already in use';
    if (raw.contains('weak-password')) return 'Password is too weak';
    if (raw.contains('network-request-failed')) return 'Network error. Try again';
    return 'Something went wrong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_signupMode ? 'Create Account' : 'Sign In')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (_signupMode) ...[
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Name is required';
                      if (s.length < 3) return 'Enter your full name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Address is required';
                      if (s.length < 6) return 'Enter a valid address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final email = (v ?? '').trim();
                    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (email.isEmpty) return 'Email is required';
                    if (!re.hasMatch(email)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _loading ? null : _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    final pass = v ?? '';
                    if (pass.isEmpty) return 'Password is required';
                    if (pass.length < 6) return 'Password must be at least 6 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _loading ? null : _resetPasswordDialog, child: const Text('Forgot password?'))),
                const SizedBox(height: 8),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                    ]),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_signupMode ? 'Create Account' : 'Sign In'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: _loading ? null : () => setState(() => _signupMode = !_signupMode), child: Text(_signupMode ? 'Have an account? Sign In' : 'New user? Create one')),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _loading ? null : _guest, icon: const Icon(Icons.person_outline), label: const Text('Continue as Guest'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}