import 'package:flutter/material.dart';
import 'package:nsm/widgets/profile_avatar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/avatar.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class AvatarForm extends StatefulWidget {
  final List<Avatar> avatars;
  final ValueChanged<int?> onAvatarSelected;
  final String currentAvatarUrl;

  const AvatarForm({
    super.key,
    required this.avatars,
    required this.onAvatarSelected,
    required this.currentAvatarUrl,
  });

  @override
  _AvatarFormState createState() => _AvatarFormState();
}

class _AvatarFormState extends State<AvatarForm> {
  int? selectedAvatarId;
  String? selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    selectedAvatarUrl = widget.currentAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextTheme textTheme = themeData.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                t(context)!.myAvatar,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 70,
                backgroundImage:
                    NetworkImage(selectedAvatarUrl ?? widget.currentAvatarUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            t(context)!.chooseYourAvatar,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: widget.avatars.length,
              itemBuilder: (context, index) {
                final avatar = widget.avatars[index];
                bool isSelected = avatar.id == selectedAvatarId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatarId = avatar.id;
                      selectedAvatarUrl = avatar.url;
                    });
                  },
                  child: ProfileAvatar(
                    imageUrl: avatar.url,
                    isSelected: isSelected,
                  ),
                );
              },
            ),
          ),
        ]),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              widget.onAvatarSelected(selectedAvatarId);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: colorScheme.secondary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: textTheme.bodyLarge,
            ),
            child: Text(t(context)!.chooseThisAvatar),
          ),
        ),
      ],
    );
  }
}
