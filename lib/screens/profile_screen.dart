import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
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
  bool isEditing = false;
  int? selectedAvatarId;

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

  void saveProfile() async {
    if (!isEditing) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final Map<String, dynamic> updatedData = {
      'email': emailController.text,
      'username': usernameController.text,
      if (selectedAvatarId != null) 'avatar': selectedAvatarId,
    };

    setState(() {
      isEditing = false;
    });

    try {
      await userProvider.updateUserProfile(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } catch (e) {
      setState(() {
        isEditing = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du profil: $e')),
      );
    }
  }

  void selectAvatar() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final avatars = await userProvider.getAvatars();
    final user = userProvider.user;

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
                final updatedData = {
                  'avatar': avatarId,
                };
                userProvider.updateUserProfile(updatedData);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextTheme textTheme = themeData.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true, // Étend le body derrière l'AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Icône de retour en blanc
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go(
                  '/'); // Retour à la page d'accueil si la pile de navigation est vide
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,
                color: Colors.white), // Icône de déconnexion en blanc
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
        backgroundColor: Colors.transparent, // Rend l'AppBar transparent
        elevation: 0, // Supprime l'ombre de l'AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'lib/assets/images/backgroundApp.png'), // Chemin vers votre image de fond
            fit: BoxFit.cover, // Couvre toute la zone du conteneur
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                    height: 10), //  espace pour déplacer le titre vers le haut
                const Text(
                  "Mon compte",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (user != null) ...[
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: selectAvatar,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(user.avatar.url),
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
                    user.username,
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
                        fillColor: Colors.blueGrey
                            .withOpacity(0.2), // Fond bleu nuit transparent
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(isEditing
                                ? 1.0
                                : 0.6), // Contour blanc avec opacité
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(isEditing
                                ? 1.0
                                : 0.6), // Contour blanc avec opacité même lorsque désactivé
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(isEditing
                                ? 1.0
                                : 0.6), // Contour blanc plus épais en mode édition
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled:
                          isEditing, // Activez l'édition si isEditing est true
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
                        fillColor: Colors.blueGrey
                            .withOpacity(0.2), // Fond bleu nuit transparent
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(isEditing
                                ? 1.0
                                : 0.6), // Contour blanc avec opacité
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(isEditing
                                ? 1.0
                                : 0.6), // Contour blanc avec opacité même lorsque désactivé
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(isEditing
                                ? 1.0
                                : 0.6), // Contour blanc plus épais en mode édition
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled:
                          isEditing, // Activez l'édition si isEditing est true
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 342,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: ElevatedButton(
                        key: ValueKey<bool>(isEditing),
                        onPressed: () {
                          setState(() {
                            if (isEditing) {
                              saveProfile();
                            }
                            isEditing = !isEditing;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: colorScheme
                              .secondary, // Utilisez une seule couleur de fond
                          minimumSize: const Size(
                              double.infinity, 50), // Taille du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Bord arrondi
                          ),
                          textStyle: textTheme.bodyLarge, // Style de texte
                        ),
                        child: Text(isEditing ? 'Valider' : 'Modifier'),
                      ),
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
