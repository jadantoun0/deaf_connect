import 'package:deafconnect/screens/do_sign.screen.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:deafconnect/widgets/common/inkwell_with_opacity.dart';
import 'package:flutter/material.dart';

class LearnSignLanguageScreen extends StatefulWidget {
  const LearnSignLanguageScreen({super.key});

  @override
  State<LearnSignLanguageScreen> createState() =>
      _LearnSignLanguageScreenState();
}

class _LearnSignLanguageScreenState extends State<LearnSignLanguageScreen> {
  final letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Sign Language'),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 5,
                childAspectRatio: 4 / 5,
              ),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                return InkwellWithOpacity(
                  onTap: () {
                    NavigationUtils.push(
                      context,
                      DoSignScreen(letter: letters[index]),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          'assets/letters/${letters[index]}.jpeg',
                        ),
                      ),
                      Text(
                        letters[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }
}
