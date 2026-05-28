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

      // Hämta bilder utan category (category = null)
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures?type=DAILY'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pictures = data
              //.where((e) => e['category'] == null && e['type'] == 'DAILY')
              .map((e) => UnknownPicture.fromJson(e))
              .toList();
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

  Future<void> _deleteDaily(int pictureId, int index) async {
    try {
      final token = await _sessionStorage.getToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures/$pictureId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _pictures.removeAt(index);
        });
      }
    } catch (e) {
      debugPrint('Kunde inte radera bilden: $e');
    }
  }

  void _showDeleteDialog(int index) {
    final picture = _pictures[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Radera bild?'),
        content: Text('Vill du ta bort "${picture.label}"?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDaily(picture.id, index);
            },
            child: const Text('Radera'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        title: const Text("Bibliotek"),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Här är dina bilder från dagens utmaning!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
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
        child: Text('Du har inga bilder än!'),
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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            picture.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.white,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () => _showDeleteDialog(index),
                          ),
                        ),
                      ),
                    ],
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