import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'login_screen.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List pictograms = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    if (!UserSession.isLoggedIn) {
      Future.microtask(() {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await Service.getPictograms();

      if (!mounted) return;

      setState(() {
        pictograms = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  Future<Map<String, String>> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location service is disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> places = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    final place = places.first;

    final address =
        "${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";

    // تم تصحيح علامة الـ $ المفقودة هنا قبل pos.latitude
    final mapsUrl =
        "https://maps.google.com/?q=${pos.latitude},${pos.longitude}";

    return {"address": address, "maps": mapsUrl};
  }

  Future<void> sendSOS(int id) async {
    try {
      final location = await getLocation();

      final message =
          "🚨 EMERGENCY SOS\n"
          "Location: ${location["address"]}\n"
          "Map: ${location["maps"]}";

      await Service.sendSOS(pictogramId: id, location: message);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("SOS sent 📩")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  IconData getIcon(String name) {
    switch (name) {
      case "hospital":
        return Icons.local_hospital;
      case "medicine":
        return Icons.medication;
      case "danger":
        return Icons.warning;
      case "fall":
        return Icons.accessibility_new;
      case "police":
        return Icons.local_police;
      case "breath":
        return Icons.air;
      default:
        return Icons.help;
    }
  }

  Color getCardColor(String name) {
    switch (name) {
      case "hospital":
        return Colors.red;
      case "medicine":
        return Colors.green;
      case "danger":
        return Colors.orange;
      case "fall":
        return Colors.purple;
      case "police":
        return Colors.blue;
      case "breath":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Emergency",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (error != null) {
                      return Center(child: Text("Error:\n$error"));
                    }

                    if (pictograms.isEmpty) {
                      return const Center(
                        child: Text("No emergency data found"),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pictograms.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (_, i) {
                        final item = pictograms[i];
                        final cardColor = getCardColor(item["iconName"] ?? "");

                        return GestureDetector(
                          onTap: () async {
                            final id = item["pictogramId"];
                            if (id == null) return;
                            await sendSOS(id);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [cardColor, cardColor.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: cardColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  child: Icon(
                                    getIcon(item["iconName"] ?? ""),
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    item["sentenceText"] ?? "",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
