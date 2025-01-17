import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant.dart';
import 'admin/reservation.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> room;

  const DetailsPage({required this.room});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? reservationInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservationStatus();
  }

  Future<void> fetchReservationStatus() async {
    final url = Uri.parse("${AppConstants.baseUrl}get_reservation.php");
    try {
      final response = await http.post(url, body: {
        'nomchambre': widget.room['nomchambre'],
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            'Réponse du backend: $data'); // Ajoute ceci pour vérifier la réponse
        if (data['is_reserved'] == true) {
          setState(() {
            reservationInfo =
                "Réservée du ${data['Date_reservation']} au ${data['Date_fin']}";
          });
        } else {
          setState(() {
            reservationInfo = "Disponible";
          });
        }
      } else {
        setState(() {
          reservationInfo = "Erreur lors de la récupération des données.";
        });
      }
    } catch (e) {
      setState(() {
        reservationInfo = "Erreur de connexion au serveur.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          // Image en haut
          Stack(
            children: [
              Container(
                height: h * 0.4,
                width: w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        "${AppConstants.baseUrl}${widget.room['profil']}"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16, // Position de l'icône de retour à gauche
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous page
                  },
                ),
              ),
              Positioned(
                top: 40,
                right: 16, // Position de l'icône de favori à droite
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    // Action pour ajouter aux favoris
                  },
                ),
              ),
            ],
          ),
          // Conteneur principal
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de la chambre et prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          child: Text(
                            widget.room['nomchambre'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "\$${widget.room['prix']} / per night",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmenity("Parking", Icons.local_parking),
                        _buildAmenity("Piscine", Icons.pool),
                        _buildAmenity("WiFi", Icons.wifi),
                      ],
                    ),
                    const SizedBox(height: 30),
// Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
// Description de la chambre
                    Text(
                      widget.room.containsKey('descriptions') &&
                              widget.room['descriptions'] != null
                          ? widget.room['descriptions']
                          : "Description non disponible",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
// Indication de réservation
                    if (isLoading)
                      const CircularProgressIndicator() // Affichage de la progression
                    else
                      reservationInfo != null
                          ? Text(
                              reservationInfo!,
                              style: TextStyle(
                                fontSize: 16,
                                color: reservationInfo == "Disponible"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              "Aucune information de réservation disponible",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    Padding(padding: EdgeInsets.only(top: 20),),
                    // Book Now Button
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationPage(
                                nomchambre: widget.room['nomchambre'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 192, 21, 78),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Book Now",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(String label, IconData icon) {
    return Card(
      child: Container(
        height: 50,
        width: 60,
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.pink),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
