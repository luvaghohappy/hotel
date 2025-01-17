import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({Key? key}) : super(key: key);

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtNomChambre = TextEditingController();
  final TextEditingController txtDescription = TextEditingController();
  final TextEditingController txtPrix = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();
  bool isLoading = false;

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    txtNomChambre.text = item['nomchambre'] ?? '';
    txtDescription.text = item['descriptions'] ?? '';
    txtPrix.text = item['prix'] ?? '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: txtNomChambre,
                  decoration: const InputDecoration(labelText: 'Nom chambre'),
                ),
                TextField(
                  controller: txtDescription,
                  decoration: const InputDecoration(labelText: 'descriptions'),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: txtPrix,
                    decoration: const InputDecoration(labelText: 'prix'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                updateData(item['id_room'].toString());
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateData(String id) async {
    final nomchambre = txtNomChambre.text;
    final descriptions = txtDescription.text;
    final prix = txtPrix.text;

    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}update.php"),
      body: {
        'id_room': id,
        'nomchambre': nomchambre,
        'descriptions': descriptions,
        'prix': prix,
      },
    );

    if (response.statusCode == 200) {
      txtNomChambre.clear();
      txtDescription.clear();
      txtPrix.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mise à jour réussie'),
        ),
      );
      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
        ),
      );
    }
  }

  Future<void> deleteData(BuildContext context, String id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment supprimer ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      var url = '${AppConstants.baseUrl}delete.php?id_room=$id';
      var response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Données supprimées avec succès');
      } else {
        print(
            'Échec de la suppression des données. Erreur: ${response.reasonPhrase}');
      }
      fetchData();
    } else {
      print('Suppression annulée');
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected'),
          ),
        );
      }
    });
  }

  Future<void> insertData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct errors before submitting'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConstants.baseUrl}add.php"),
    );

    request.fields['nomchambre'] = txtNomChambre.text.trim();
    request.fields['descriptions'] = txtDescription.text.trim();
    request.fields['prix'] = txtPrix.text.trim();

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profil', // Matches the backend key
          _imageFile!.path,
        ),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);

        if (responseJson['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully added the room'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form and reset the image
          setState(() {
            _imageFile = null;
            txtNomChambre.clear();
            txtDescription.clear();
            txtPrix.clear();
          });

          // Refresh the list
          fetchData();
        } else {
          throw Exception(responseJson['error']);
        }
      } else {
        throw Exception('Failed to save the room');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: txtNomChambre,
                            label: 'Room Name',
                            icon: Icons.hotel,
                            validatorMessage: 'Please enter the room name',
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: txtDescription,
                            label: 'Description',
                            icon: Icons.description,
                            maxLines: 3,
                            validatorMessage: 'Please enter the description',
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: txtPrix,
                            label: 'Price',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validatorMessage: 'Please enter the price',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.image, color: Colors.blue),
                                onPressed: getImage,
                                tooltip: 'Pick Image',
                              ),
                              if (_imageFile != null)
                                const Text(
                                  'Image Selected',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          IconButton(
                            icon: const Icon(Icons.save,
                                color: Colors.green, size: 30),
                            onPressed: insertData,
                            tooltip: 'Save Room',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Available Rooms:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: SizedBox(
                              width: 60, // Constrain the width
                              height: 60,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded image
                                child: Image.network(
                                  "${AppConstants.baseUrl}${item['profil']}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image,
                                        size: 50, color: Colors.red);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              item['nomchambre'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              '${item['prix']} - ${item['descriptions']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            trailing: SizedBox(
                              width: 60,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      _showEditDialog(item);
                                    },
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                  IconButton(
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteData(context, item['id_room']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }
}
