import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Preview.dart'; // Your preview screen

class WorkoutEntryScreen extends StatelessWidget {
  final String clientId;
  final String weekId;
  final String dayId;

  const WorkoutEntryScreen({
    super.key,
    required this.clientId,
    required this.weekId,
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController setsController = TextEditingController();
    final TextEditingController repsController = TextEditingController();
    final TextEditingController linkController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('WEEK ${weekId.replaceAll('week', '')}'),
                      _buildLabel('D ${dayId.replaceAll('day', '')}'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('EXERCISE'),
                  _buildInputField(controller: exerciseController),
                  _buildSectionTitle('SETS'),
                  _buildInputField(controller: setsController),
                  _buildSectionTitle('REP RANGE'),
                  _buildInputField(controller: repsController),
                  _buildSectionTitle('LINK'),
                  _buildInputField(controller: linkController),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton('BACK', () {
                        Navigator.pop(context);
                      }),
                      _buildActionButton('DONE', () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('clients')
                              .doc(clientId)
                              .collection('weeks')
                              .doc(weekId)
                              .collection('days')
                              .doc(dayId)
                              .collection('exerciseData')
                              .add({
                            'clientId': clientId,
                            'exercise': exerciseController.text.trim(),
                            'sets': setsController.text.trim(),
                            'reps': repsController.text.trim(),
                            'link': linkController.text.trim(),
                            'timestamp': Timestamp.now(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Workout data saved!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Failed to save: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildActionButton('PREVIEW', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkoutPreviewScreen(clientId: clientId),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A2C3C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontSize: 14,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A2C3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
