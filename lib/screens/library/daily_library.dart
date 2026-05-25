import 'package:flutter/material.dart';
import '../../services/session_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/custom_navigation_bar.dart';

class UnknownPicture {
  final int id;
  final String label;
  final String imageUrl;

  UnknownPicture({
    required this.id,
    required this.label,
    required this.imageUrl,
  });

  factory UnknownPicture.fromJson(Map<String, dynamic> json) {
    return UnknownPicture(
      id: json['id'],
      label: json['label'],
      imageUrl: json['imageUrl'],
    );
  }
}

class DailyLibrary extends StatefulWidget {
  const DailyLibrary({super.key});

  @override
  State<DailyLibrary> createState() => _DailyLibraryState();
}

class _DailyLibraryState extends State<DailyLibrary> {
  final SessionStorage _sessionStorage = SessionStorage();

  List<UnknownPicture> _pictures = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDailyPictures();
  }

  Future<void> _fetchDailyPictures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _sessionStorage.getToken();

      if (token == null) {
        setState(() {
          _errorMessage = 'Du är inte inloggad';
          _isLoading = false;
        });
        return;
      }

      // Hämta bilder med pictureMode=CHALLENGE (daily challenge-bilder)
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures?pictureMode=CHALLENGE'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pictures = data.map((e) => UnknownPicture.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Kunde inte hämta bilder (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Nätverksfel: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        title: Text("Bibliotek"),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: SizedBox(
                width: 200,
                child: Text(
                  'Mina dagliga utmaningar',
                  style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 2),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDailyPictures,
              child: const Text('Något är fel, försök igen'),
            ),
          ],
        ),
      );
    }

    if (_pictures.isEmpty) {
      return const Center(
        child: Text('Du har inte klarat några dagliga utmaningar än!'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: _pictures.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _pictures.length <= 3 ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _pictures.length <= 3 ? 1.4 : 0.8,
        ),
        itemBuilder: (context, index) {
          final picture = _pictures[index];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfff8ed76),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      picture.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white,
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.white,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  picture.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}