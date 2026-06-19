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
      appBar: AppBar(
        title: const Text(
          "Translated Sentence",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  sentence.isEmpty
                      ? "No sentence yet"
                      : sentence,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),

                label: const Text(
                  "Clear Sentence",
                ),

                onPressed: () {

                  onClear();

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
