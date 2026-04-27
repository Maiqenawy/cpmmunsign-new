import 'package:flutter/material.dart';
import 'package:cominsign/lib/core/service/api-service.dart';
import 'newcontact_page.dart';
import '../widgets/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List contacts = [];
  String token = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    loadContacts();
  }

 Future<void> loadContacts() async {
  try {
    final data = await Service.getContacts();
    setState(() => contacts = data);
  } catch (e) {
    print(e);
  }
}

Future<void> deleteContact(int id) async {
  await Service.deleteContact(id);
  loadContacts();
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

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.contacts, color: cs.onSurface, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      "Contacts",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List
              Expanded(
                child: contacts.isEmpty
                    ? Center(
                        child: Text(
                          "No Contacts",
                          style: TextStyle(color: cs.onSurface),
                        ),
                      )
                    : ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final c = contacts[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: cs.surface,
                                child: Icon(Icons.person,
                                    color: cs.onSurface),
                              ),
                              title: Text(
                                c["name"],
                                style: TextStyle(color: cs.onSurface),
                              ),
                              subtitle: Text(
                                "${c["email"]} • ${c["relation"] ?? ""}",
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: cs.primary),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              NewContactPage(contact: c),
                                        ),
                                      ).then((_) => loadContacts());
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        deleteContact(c["contactId"]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewContactPage(),
            ),
          ).then((_) => loadContacts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
