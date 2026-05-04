import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class NewContactPage extends StatefulWidget {
  final dynamic contact;

  const NewContactPage({super.key, this.contact});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController relation = TextEditingController();

  bool isLoading = false;
  bool hasSearched = false;

  List results = [];
  int? selectedUserId;

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      name.text = widget.contact["name"] ?? "";
      email.text = widget.contact["email"] ?? "";
      relation.text = widget.contact["relation"] ?? "";
      selectedUserId = widget.contact["contactUserId"];
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    relation.dispose();
    super.dispose();
  }

  // ================= SEARCH =================
  Future<void> search() async {
    if (email.text.trim().isEmpty) return;

    if (email.text.trim().toLowerCase() ==
        UserSession.email?.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't add yourself")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      final data = await Service.searchUser(email.text.trim());
      setState(() {
        results = data;
      });
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  // ================= SAVE =================
  Future<void> save() async {
    if (name.text.isEmpty || email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name & Email required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.contact == null) {
        await Service.addContact(
          name: name.text.trim(),
          email: email.text.trim(),
          relation: relation.text.trim(),
        );
      } else {
        await Service.updateContact(
          contactId: widget.contact["contactId"],
          name: name.text.trim(),
          email: email.text.trim(),
          relation: relation.text.trim(),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      debugPrint("SAVE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving contact")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text("Cancel",
                          style: TextStyle(color: cs.primary)),
                    ),
                    Text(
                      widget.contact == null
                          ? "New Contact"
                          : "Edit Contact",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: save,
                      child: Text("Done",
                          style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _card([
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: "Search by email",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: search,
                      ),
                    ),
                  ),
                ], cs),

                const SizedBox(height: 15),

                if (results.isEmpty && !isLoading && hasSearched)
                  const Text("No user found"),

                ...results.map((u) => _card([
                      ListTile(
                        title: Text(u["name"] ?? ""),
                        subtitle: Text(u["email"] ?? ""),
                        onTap: () {
                          setState(() {
                            selectedUserId = u["id"];
                            email.text = u["email"] ?? "";
                            name.text = u["name"] ?? "";
                            results.clear();
                          });
                        },
                      )
                    ], cs)),

                const SizedBox(height: 15),

                _field(name, "Name"),
                const SizedBox(height: 15),
                _field(email, "Email"),
                const SizedBox(height: 15),
                _field(relation, "Relation"),

                const SizedBox(height: 20),

                if (isLoading) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}