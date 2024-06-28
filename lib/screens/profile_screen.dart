import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsm/models/user.dart';
import 'package:nsm/services/user_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/avatar_form.dart';
import '../widgets/bottom_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late AuthProvider authProvider;
  late UserService userService;
  User? user;
  int? selectedAvatarId;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    this.authProvider = authProvider;
    this.userService = userService;
    user = authProvider.user;
    emailController = TextEditingController(text: user?.email ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void saveProfile() async {
    final Map<String, dynamic> updatedData = {
      'email': emailController.text,
      'username': usernameController.text,
    };

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await userService.updateProfile(updatedData);
      await authProvider.loadCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
      setState(() {
        user = authProvider.user;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du profil: $e')),
      );
    }
  }

  void saveAvatar(int avatarId) async {
    final Map<String, dynamic> updatedData = {
      'avatar': avatarId,
    };

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await userService.updateProfile(updatedData);
      await authProvider.loadCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar mis à jour avec succès')),
      );
      setState(() {
        user = authProvider.user;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour de l\'avatar: $e')),
      );
    }
  }

  void selectAvatar() async {
    final avatars = await userService.getAvatars();

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: AvatarForm(
            avatars: avatars,
            currentAvatarUrl: user!.avatar.url,
            onAvatarSelected: (int? avatarId) {
              Navigator.of(context).pop();
              if (avatarId != null) {
                setState(() {
                  selectedAvatarId = avatarId;
                });
                saveAvatar(avatarId);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextTheme textTheme = themeData.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/backgroundApp.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                const Text(
                  "Mon compte",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (authProvider.user != null) ...[
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: selectAvatar,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage:
                              NetworkImage(authProvider.user!.avatar.url),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: selectAvatar,
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.user!.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 342,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Mail',
                        labelStyle: const TextStyle(color: Colors.white),
                        fillColor: Colors.blueGrey.withOpacity(0.2),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 342,
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Pseudo',
                        labelStyle: const TextStyle(color: Colors.white),
                        fillColor: Colors.blueGrey.withOpacity(0.2),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 342,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: colorScheme.secondary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: textTheme.bodyLarge,
                      ),
                      child: const Text('Valider'),
                    ),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
