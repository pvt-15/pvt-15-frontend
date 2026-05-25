import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../../services/translation_service.dart';

class PlantPicture {
  final int id;
  final String label;
  final String imageUrl;
  final double aiConfidence;

  PlantPicture({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.aiConfidence,
  });

  factory PlantPicture.fromJson(Map<String, dynamic> json) {
    return PlantPicture(
      id: json['id'],
      label: json['label'],
      imageUrl: json['imageUrl'],
      aiConfidence: (json['aiConfidence'] as num).toDouble(),
    );
  }
}

class PlantsLibrary extends StatefulWidget {
  const PlantsLibrary({super.key});

  @override
  State<PlantsLibrary> createState() => _PlantsLibraryState();
}

class _PlantsLibraryState extends State<PlantsLibrary> {
  final SessionStorage _sessionStorage = SessionStorage();

  List<PlantPicture> _plants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
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

      // Hämta alla tre kategorier parallellt
      final categories = ['FLOWER', 'PLANT', 'TREE'];
      final responses = await Future.wait(
        categories.map((category) => http.get(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures?category=$category'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )),
      );

      // Slå ihop alla listor
      final List<PlantPicture> allPlants = [];
      for (final response in responses) {
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          //allPlants.addAll(data.map((e) => PlantPicture.fromJson(e))); //används om vi inte ska översätta artnamn
          //Översätter artnamn
          for (final item in data) {

            final plant = PlantPicture.fromJson(item);

            final translatedLabel =
            await TranslationService.translateWord(plant.label);

            allPlants.add(
              PlantPicture(
                id: plant.id,
                label: translatedLabel,
                imageUrl: plant.imageUrl,
                aiConfidence: plant.aiConfidence,
              ),
            );
          }
        }
      }

      setState(() {
        _plants = allPlants;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Nätverksfel: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePlant(int pictureId, int index) async {
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
          _plants.removeAt(index);
        });
      }
    } catch (e) {
      debugPrint('Kunde inte radera bilden: $e');
    }
  }

  void _showDeleteDialog(int index) {
    final plant = _plants[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Radera bild?'),
        content: Text('Vill du ta bort "${plant.label}"?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlant(plant.id, index);
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
        elevation: 0,
        title: Text("Bibliotek"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Mina växter',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: 2,
      ),
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
              onPressed: _fetchPlants,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_plants.isEmpty) {
      return const Center(
        child: Text('Du har inte hittat några växter än!'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: _plants.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _plants.length <= 3 ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _plants.length <= 3 ? 1.4 : 0.8,
        ),
        itemBuilder: (context, index) {
          final plant = _plants[index];
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
                            plant.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.white,
                              child: const Icon(Icons.local_florist, size: 50),
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
                            icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                            onPressed: () => _showDeleteDialog(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  plant.label,
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