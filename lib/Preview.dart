import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutPreviewScreen extends StatelessWidget {
  final String clientId;

  const WorkoutPreviewScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Workout Preview'),
        backgroundColor: const Color(0xFF4A2C3C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('exerciseData')
            .where('clientId', isEqualTo: clientId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No workouts found.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final exercises = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final data = exercises[index].data() as Map<String, dynamic>;
              final docRefPath = exercises[index].reference.path;
              final pathParts = docRefPath.split('/');
              final weekId = pathParts[pathParts.indexOf('weeks') + 1];
              final dayId = pathParts[pathParts.indexOf('days') + 1];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('WEEK ${weekId.replaceAll('week', '')}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('D ${dayId.replaceAll('day', '')}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Exercise: ${data['exercise'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white)),
                    Text('Sets: ${data['sets'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white)),
                    Text('Reps: ${data['reps'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white)),
                    Text('Link: ${data['link'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Exercise'),
                              content: const Text(
                                  'Are you sure you want to delete this entry?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await exercises[index].reference.delete();
                          }
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
