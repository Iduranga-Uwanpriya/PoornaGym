import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EC_Page1.dart'; // HomePage

class ClientNameScreen extends StatelessWidget {
  const ClientNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2C3C),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(
                  child: Text(
                    'CLIENT NAME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  hintText: 'Enter client name',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a client name"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // 🔍 Check if client with the same name already exists
                      final query = await FirebaseFirestore.instance
                          .collection('clients')
                          .where('name', isEqualTo: name)
                          .limit(1)
                          .get();

                      late final String clientId;

                      if (query.docs.isNotEmpty) {
                        // ✅ Use existing client
                        clientId = query.docs.first.id;
                      } else {
                        // ➕ Create new client
                        final docRef = await FirebaseFirestore.instance
                            .collection('clients')
                            .add({
                          'name': name,
                          'createdAt': Timestamp.now(),
                        });
                        clientId = docRef.id;
                      }

                      // ✅ Navigate to HomePage with the clientId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(clientId: clientId),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Failed to create client: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 4,
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
