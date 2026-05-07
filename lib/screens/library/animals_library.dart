import 'package:flutter/material.dart';
import '../../services/token_storage.dart'; // justera sökvägen efter ditt projekt
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimalPicture {
  final int id;
  final String label;
  final String imageUrl;
  final double aiConfidence;

  AnimalPicture({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.aiConfidence,
  });

  factory AnimalPicture.fromJson(Map<String, dynamic> json) {
    return AnimalPicture(
      id: json['id'],
      label: json['label'],
      imageUrl: json['imageUrl'],
      aiConfidence: (json['aiConfidence'] as num).toDouble(),
    );
  }
}

class AnimalsLibrary extends StatefulWidget {
  const AnimalsLibrary({super.key});

  @override
  State<AnimalsLibrary> createState() => _AnimalsLibraryState();
}

class _AnimalsLibraryState extends State<AnimalsLibrary> {
  final TokenStorage _tokenStorage = TokenStorage();

  List<AnimalPicture> _animals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  Future<void> _fetchAnimals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        setState(() {
          _errorMessage = 'Du är inte inloggad';
          _isLoading = false;
        });
        return;
      }

      // Hämta alla tre kategorier av djur parallellt
      final categories = ['INSECT', 'BIRD', 'ANIMAL'];
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
      final List<AnimalPicture> allAnimals = [];
      for (final response in responses) {
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          allAnimals.addAll(data.map((e) => AnimalPicture.fromJson(e)));
        }
      }

      setState(() {
        _animals = allAnimals;
        _isLoading = false;
      });

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
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C290C)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Mina djur',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
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
              onPressed: _fetchAnimals,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_animals.isEmpty) {
      return const Center(
        child: Text('Du har inte hittat några djur än!'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: _animals.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _animals.length <= 3 ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _animals.length <= 3 ? 1.4 : 0.8,
        ),
        itemBuilder: (context, index) {
          final animal = _animals[index];
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
                      animal.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white,
                        child: const Icon(Icons.emoji_nature, size: 50),
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
                const SizedBox(height: 10),
                Text(
                  animal.label,
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





/*
import 'package:flutter/material.dart';


class AnimalsLibrary extends StatefulWidget{
  const AnimalsLibrary({super.key});

  @override
  State<AnimalsLibrary> createState() => _AnimalsLibrary();
}

class _AnimalsLibrary extends State<AnimalsLibrary> {
// Ändra sen när vi har riktiga bilder
  final List<String> animals = [
    'Älg',
    'Humla',
    'Myra',
    'Ko',
    'Snigel',
    'Ekorre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Mina djur',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Grid för bilder
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:GridView.builder(
                    itemCount: animals.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: animals.length <= 3 ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: animals.length <= 3 ? 1.4 : 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xfff8ed76),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.emoji_nature,
                                  size: 50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              animals[index],
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 */