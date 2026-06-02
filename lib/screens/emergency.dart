import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'package:geolocator/geolocator.dart';
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

    print("IS LOGGED IN: ${UserSession.isLoggedIn}");

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

  Future<String> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location service is disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return "${pos.latitude},${pos.longitude}";
  }

  Future<void> sendSOS(int id) async {
    try {
      String location = await getLocation();

      await Service.sendSOS(
        pictogramId: id,
        location: location,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SOS sent 📩")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (error != null) {
                      return Center(
                        child: Text(
                          "Error:\n$error",
                          textAlign: TextAlign.center,
                        ),
                      );
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

                        return GestureDetector(
                          onTap: () {
                            final id = item["pictogramId"];

                            if (id == null) return;

                            sendSOS(id);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  getIcon(item["iconName"] ?? ""),
                                  size: 50,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    item["sentenceText"] ?? "",
                                    textAlign: TextAlign.center,
                                  ),
                                )
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