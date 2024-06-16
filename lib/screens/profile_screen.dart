import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsm/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController emailController;
  late TextEditingController usernameController;
  bool isEditing = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    emailController = TextEditingController(text: user?.email);
    usernameController = TextEditingController(text: user?.username);
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  static const List<String> _routes = [
    '/profile',
    '/',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  void saveProfile() {
    // TODO: Implémentez la logique de mise à jour du profil
    // Après la mise à jour, désactivez le mode édition
    toggleEdit();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F0E17),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (user != null) ...[
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Mail'),
                  enabled:
                      isEditing, // Le champ est modifiable seulement en mode édition
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Pseudo'),
                  enabled:
                      isEditing, // Le champ est modifiable seulement en mode édition
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isEditing ? saveProfile : toggleEdit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(isEditing ? 'Valider' : 'Modifier'),
                ),
              ] else ...[
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onAddButtonPressed: () => context.go("/home"),
        isProfileScreen: true,
      ),
    );
  }
}
