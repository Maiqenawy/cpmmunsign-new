import 'package:flutter/material.dart';

class SentenceScreen extends StatelessWidget {
  final String sentence;
  final VoidCallback onClear;

  const SentenceScreen({
    super.key,
    required this.sentence,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Translated Sentence",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor:
                        Colors.deepPurple.withOpacity(0.2),

                    child: const Icon(
                      Icons.translate,
                      color: Colors.deepPurple,
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SingleChildScrollView(
                    child: Text(
                      sentence.isEmpty
                          ? "No sentence yet"
                          : sentence,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),

                label: const Text(
                  "Start New Sentence",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E35B1),
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {
                  onClear();
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
