import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class NewContactPage extends StatefulWidget {
  final dynamic contact;

  const NewContactPage({super.key, this.contact});

  @override
  State<NewContactPage> createState() =>
      _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController relation = TextEditingController();

  List results = [];
  int? selectedUserId;

  String? token = UserSession.token;

  bool isLoading = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      relation.text = widget.contact["relation"] ?? "";
      email.text = widget.contact["email"] ?? "";
      selectedUserId = widget.contact["contactUserId"];
    }
  }

  @override
  void dispose() {
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
      final data = await Service.searchUser(
        email.text.trim(),
        token!,
      );

      setState(() {
        results = data;
      });
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  // ================= SAVE =================
  Future<void> save() async {
    if (token == null) return;

    if (widget.contact == null && selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select user first")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.contact == null) {
        await Service.addContact(
          selectedUserId!,
          relation.text.trim(),
          token!,
        );
      } else {
        await Service.updateContact(
          widget.contact["contactId"],
          relation.text.trim(),
          token!,
        );
      }

      Navigator.pop(context);
    } catch (e) {
      debugPrint("SAVE ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: cs.primary),
                      ),
                    ),
                    Text(
                      widget.contact == null
                          ? "New Contact"
                          : "Edit Contact",
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: save,
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

                if (results.isEmpty &&
                    !isLoading &&
                    hasSearched)
                  const Text("No user found"),

                ...results.map((u) => _card([
                      ListTile(
                        title: Text(u["name"] ?? ""),
                        subtitle: Text(u["email"] ?? ""),
                        onTap: () {
                          setState(() {
                            selectedUserId = u["id"];
                            email.text = u["email"] ?? "";
                            results.clear();
                          });
                        },
                      )
                    ], cs)),

                const SizedBox(height: 15),

                _card([
                  TextField(
                    controller: relation,
                    decoration: const InputDecoration(
                      hintText: "Relation",
                      border: InputBorder.none,
                    ),
                  )
                ], cs),

                const SizedBox(height: 20),

                if (isLoading)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}
