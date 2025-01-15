import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constant.dart';

class ReservationPage extends StatefulWidget {
  final String nomchambre;

  const ReservationPage({required this.nomchambre, Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedsexe; // To store the selected sexe
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _postnomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _dateReservationController =
      TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();

  Future<void> submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
        ),
      );
      return;
    }

    final url = Uri.parse("${AppConstants.baseUrl}insert.php");
    final response = await http.post(
      url,
      body: {
        'nom': _nomController.text.trim(),
        'postnom': _postnomController.text.trim(),
        'sexe': selectedsexe,
        'numero': _numeroController.text.trim(),
        'nomchambre': widget.nomchambre, // Pass the selected room name
        'Date_reservation': _dateReservationController.text.trim(),
        'Date_fin': _dateFinController.text.trim(),
      },
    );

    if (response.statusCode == 200) {
      final result = response.body;
      if (result.contains("success")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation successful!'),
          ),
        );
        Navigator.pop(context); // Go back to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation failed'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting reservation'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Card Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 33, 98, 211),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.credit_card, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Reservation for: ${widget.nomchambre}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reservation Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Fields
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _postnomController,
                        label: 'Postnom',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 10),

                      // Dropdown for Sexe
                      DropdownButtonFormField<String>(
                        value: selectedsexe,
                        decoration: InputDecoration(
                          labelText: "Sexe",
                          prefixIcon: const Icon(Icons.wc, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "M",
                            child: Text("Male"),
                          ),
                          DropdownMenuItem(
                            value: "F",
                            child: Text("Female"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedsexe = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a sexe' : null,
                      ),

                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _numeroController,
                        label: 'Numero',
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _dateReservationController,
                        label: 'Date Reservation',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            _dateReservationController.text =
                                selectedDate.toIso8601String().split('T').first;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _dateFinController,
                        label: 'Date Fin',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            _dateFinController.text =
                                selectedDate.toIso8601String().split('T').first;
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Button
                      Center(
                        child: ElevatedButton(
                          onPressed: submitReservation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Confirm Reservation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }
}
