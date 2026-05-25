import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Skogsjakten/services/session_storage.dart';

/// Skärm för att byta lösenord när användaren är inloggad.
///
/// Tre fält: nuvarande lösenord, nytt lösenord, bekräfta nytt lösenord.
/// Samma kriterier som vid kontoskapande: min 10 tecken, minst en stor
/// bokstav och minst en siffra.
///
/// Skickar PATCH /auth-service/users/me/password med JWT från SessionStorage.
/// Backend verifierar gammalt lösenord innan det nya sparas.
class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final SessionStorage _sessionStorage = SessionStorage();
  bool _submitting = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      final token = await _sessionStorage.getToken();
      if (token == null) {
        if (!mounted) return;
        _showSnack('Du måste vara inloggad för att byta lösenord');
        return;
      }

      final response = await http.patch(
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/auth-service/users/me/password',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 204 || response.statusCode == 200) {
        _showSnack('Lösenordet har ändrats');
        Navigator.pop(context);
      } else {
        // Backend skickar tillbaka felmeddelandet som plain text body, t.ex.
        // "Incorrect current password" eller "Password must contain a digit".
        final message = response.body.isNotEmpty
            ? response.body
            : 'Kunde inte ändra lösenord (status ${response.statusCode})';
        _showSnack(_translateBackendError(message));
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Nätverksfel: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  /// Översätter de engelska felmeddelanden från backend till svenska.
  /// Faller tillbaka på orginalmeddelandet om ingen träff hittas.
  String _translateBackendError(String backendMessage) {
    const map = {
      'Old password is required': 'Nuvarande lösenord saknas',
      'New password is required': 'Nytt lösenord saknas',
      'Incorrect current password': 'Felaktigt nuvarande lösenord',
      'Password can only be changed for local accounts':
      'Du kan inte ändra lösenord för Google-konton',
      'New password must differ from the current password':
      'Nytt lösenord måste skilja sig från det gamla',
      'Password must be at least 10 characters':
      'Lösenordet måste vara minst 10 tecken',
      'Password must contain an uppercase letter':
      'Lösenordet måste innehålla en stor bokstav',
      'Password must contain a digit': 'Lösenordet måste innehålla en siffra',
      'User not found': 'Användaren hittades inte',
    };
    return map[backendMessage.trim()] ?? backendMessage;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center)),
    );
  }

  // Samma validatorer som i create_account.dart.
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Ogiltigt lösenord';
    if (value.length < 10) return 'Lösenordet måste vara minst 10 tecken';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Lösenordet måste innehålla en stor bokstav';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Lösenordet måste innehålla en siffra';
    }
    return null;
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) return 'Fyll i nuvarande lösenord';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Bekräfta lösenord';
    if (value != _newPasswordController.text) return 'Lösenorden matchar inte';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Ändra lösenord'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: TextFormField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nuvarande lösenord',
                    ),
                    validator: _validateOldPassword,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nytt lösenord',
                    ),
                    validator: _validateNewPassword,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Bekräfta nytt lösenord',
                    ),
                    validator: _validateConfirm,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Bekräfta nytt lösenord'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}