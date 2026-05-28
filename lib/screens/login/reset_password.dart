import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Skärm för "Glömt lösenord".
///
/// Användaren fyller i sin e-postadress och får ett mejl med en länk för att
/// välja ett nytt lösenord. Själva återställningen sker på en webbsida som
/// auth-service serverar; den här skärmen startar bara flödet.
///
/// Skickar POST /auth-service/auth/forgot-password med { "email": ... }.
/// Backend svarar alltid 200 med ett generiskt meddelande om e-posten kan
/// kopplas till ett lokalt konto (för att inte avslöja vilka adresser som är
/// registrerade). Google-konton saknar lösenord och nekas med status 409.
class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/auth-service/auth/forgot-password',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Visa bekräftelsevyn oavsett om adressen fanns eller inte.
        setState(() => _sent = true);
      } else {
        final message = response.body.isNotEmpty
            ? response.body
            : 'Något gick fel (status ${response.statusCode})';
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

  /// Översätter backendens engelska felmeddelanden till svenska.
  String _translateBackendError(String backendMessage) {
    const map = {
      'Email is required': 'Fyll i din e-postadress',
      'This account uses Google sign-in and has no password to reset':
      'Det här kontot loggar in med Google och har inget lösenord att '
          'återställa. Logga in med Google istället.',
    };
    return map[backendMessage.trim()] ?? backendMessage;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center)),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Fyll i din e-postadress';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Ogiltig e-postadress';
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
        title: const Text('Återställ lösenord'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _sent ? _buildSentView(context) : _buildFormView(context),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              'Ange e-postadressen för ditt konto så skickar vi en länk för '
                  'att välja ett nytt lösenord.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-post',
            ),
            validator: _validateEmail,
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
                : const Text('Skicka återställningslänk'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSentView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.mark_email_read_outlined, size: 72),
        const SizedBox(height: 20),
        Text(
          'Kolla din inkorg',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Om det finns ett konto kopplat till adressen har vi skickat en '
              'länk för att återställa lösenordet. Länken är giltig i 30 minuter.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tillbaka till inloggning'),
        ),
      ],
    );
  }
}