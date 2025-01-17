import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin/reservation.dart';
import 'constant.dart';
import 'detail.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}charger.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToDetails(Map<String, dynamic> room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 192, 21, 78),
        title: const Text(
          "BENEHOTEL",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginAdmin(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Rechercher...',
                  prefixIcon: const Icon(Icons.search,
                      color: Color.fromARGB(255, 192, 21, 78)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Boutons de catégorie
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  categoryButton("ALL"),
                  categoryButton("Single Room"),
                  categoryButton("Double Room"),
                  categoryButton("Luxury Room"),
                ],
              ),
            ),

            // Liste des chambres
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: items.map((room) {
                      return GestureDetector(
                        onTap: () => navigateToDetails(room),
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.network(
                                  "${AppConstants.baseUrl}${room['profil']}",
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Informations
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          room['nomchambre'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              room['location'] ?? 'Inconnu',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      children: [
                                        Text(
                                          "\$${room['prix'] ?? 'N/A'} / nuit",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              room['rating'] ?? '4.5',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget categoryButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: () {
          // Filtrer par catégorie
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.pink.shade800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

