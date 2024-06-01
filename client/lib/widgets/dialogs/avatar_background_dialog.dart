import 'package:deafconnect/models/avatar_background.model.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:flutter/material.dart';

List<AvatarBackground> backgrounds = [
  AvatarBackground(
    name: 'Transparent',
    path: 'assets/backgrounds/transparent.png',
    value: '',
  ),
  AvatarBackground(
    name: 'Beach',
    path: 'assets/backgrounds/beach.jpg',
    value: 'Beach',
  ),
  AvatarBackground(
    name: 'Mountain',
    path: 'assets/backgrounds/mountains.jpg',
    value: 'Mountains',
  ),
  AvatarBackground(
    name: 'Christmas',
    path: 'assets/backgrounds/Christmas.jpg',
    value: 'Christmas',
  ),
  AvatarBackground(
    name: 'Moon',
    path: 'assets/backgrounds/Moon.jpg',
    value: 'Moon',
  ),
];

String getPathFromValue(String value) {
  for (var bg in backgrounds) {
    if (bg.value == value) {
      return bg.path;
    }
  }
  return '';
}

showBackgroundsDialog({
  required BuildContext context,
  required Function onChange,
  required String bgImage,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
        height: 350,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Backgrounds',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: false,
                  itemCount: backgrounds.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 30,
                    childAspectRatio: 8 / 11,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onChange(backgrounds[index].value);
                        NavigationUtils.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: bgImage == backgrounds[index].value
                                    ? mainColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgrounds[index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 100,
                                width: 100,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            backgrounds[index].name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
