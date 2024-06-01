import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

showChooseAvatarDialog(BuildContext context, {required Function onChange}) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your avatar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Consumer<StoreProvider>(
                builder: (context, storeProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          storeProvider.setFemale(true);
                          NavigationUtils.pop(context);
                          onChange();
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/avatars/girl.jpg'),
                                  fit: BoxFit.contain,
                                ),
                                border: Border.all(
                                  color: storeProvider.isFemale
                                      ? mainColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text('Ava', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          storeProvider.setFemale(false);
                          NavigationUtils.pop(context);
                          onChange();
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/avatars/boy.jpg'),
                                  fit: BoxFit.contain,
                                ),
                                border: Border.all(
                                  color: !storeProvider.isFemale
                                      ? mainColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Leo',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      );
    },
  );
}
