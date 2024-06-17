import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class JoinUs extends StatefulWidget {
  const JoinUs({Key? key}) : super(key: key);

  @override
  _JoinUsState createState() => _JoinUsState();
}

class _JoinUsState extends State<JoinUs> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isRegisterView = false;

  Future<void> loginUser() async {
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Adresse email est requise';
      });
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Mot de passe est requis';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(emailController.text, passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        errorMessage = 'Échec de la connexion: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> registerUser() async {
    if (usernameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Nom d\'utilisateur est requis';
      });
      return;
    }
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Adresse email est requise';
      });
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Mot de passe est requis';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.register(
        usernameController.text,
        emailController.text,
        passwordController.text,
      );

      if (response.containsKey('data')) {
        setState(() {
          isRegisterView = false;
          errorMessage = '';
          // Effacer les champs de saisie après l'inscription réussie
          usernameController.clear();
          emailController.clear();
          passwordController.clear();
        });
      } else {
        setState(() {
          errorMessage = 'Échec de l\'inscription';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Échec de l\'inscription: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            isRegisterView
                ? 'Crée ton compte et décolle vers l\'infini !'
                : 'Identifie-toi et embarque vers l\'infini',
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Image.asset(
              isRegisterView
                  ? 'lib/assets/images/register.png'
                  : 'lib/assets/images/login.png',
            ),
          ),
        ),
        const SizedBox(height: 2),
        if (isRegisterView)
          Container(
            width: 342,
            height: 53,
            decoration: BoxDecoration(
              color: const Color(0xFF232136),
              border: Border.all(color: const Color(0x66FFFFFF)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                labelText: 'Nom d\'utilisateur',
                labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          width: 342,
          height: 53,
          decoration: BoxDecoration(
            color: const Color(0xFF232136),
            border: Border.all(color: const Color(0x66FFFFFF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              labelText: 'Adresse email',
              labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 342,
          height: 53,
          decoration: BoxDecoration(
            color: const Color(0xFF232136),
            border: Border.all(color: const Color(0x66FFFFFF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              labelText: 'Mot de passe',
              labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 342,
          child: ElevatedButton(
            onPressed:
                isLoading ? null : (isRegisterView ? registerUser : loginUser),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    isRegisterView ? 'Créer mon compte' : 'Connexion',
                    style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isRegisterView = !isRegisterView;
                errorMessage = '';
              });
            },
            child: Text(
              isRegisterView ? 'J’ai déjà un compte' : 'Je n\'ai pas de compte',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
