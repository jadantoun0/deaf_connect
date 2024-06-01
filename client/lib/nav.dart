import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/screens/chat.screen.dart';
import 'package:deafconnect/screens/learn_sign_language.screen.dart';
import 'package:deafconnect/screens/text_to_sign.screen.dart';
import 'package:deafconnect/screens/transcripts.screen.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      const ChatScreen(),
      const TranscriptsScreen(),
      const TextToSignScreen(),
      // const P2PVideo(),
      const LearnSignLanguageScreen(),
    ];
  }

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return Scaffold(
          backgroundColor: secondaryColor,
          // body: PageStorage(
          //   bucket: bucket,
          //   child: screens[storeProvider.selectedTab],
          // ),
          body: IndexedStack(
            index: storeProvider.selectedTab,
            children: screens,
          ),
          bottomNavigationBar: BottomAppBar(
            surfaceTintColor: Colors.white,
            shape: const CircularNotchedRectangle(),
            padding: EdgeInsets.zero,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMaterialButton(
                    index: 0,
                    label: "Chat",
                    iconName: 'chat.svg',
                  ),
                  _buildMaterialButton(
                    index: 1,
                    label: "Transcripts",
                    iconName: 'transcripts.svg',
                  ),
                  _buildMaterialButton(
                    index: 2,
                    label: "Text to Sign",
                    iconName: 'sign.svg',
                  ),
                  _buildMaterialButton(
                    index: 3,
                    label: "Sign to Text",
                    iconName: 'camera.svg',
                  ),
                  // _buildMaterialButton(
                  //   index: 4,
                  //   label: "Settings",
                  //   iconName: 'settings.svg',
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialButton({
    required String label,
    required String iconName,
    required int index,
  }) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        return SizedBox(
          width: 70,
          child: MaterialButton(
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              setState(() {
                storeProvider.updateSelectedTab(index);
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/navbar/$iconName',
                  width: 32,
                  colorFilter: storeProvider.selectedTab == index
                      ? const ColorFilter.mode(mainColor, BlendMode.srcIn)
                      : const ColorFilter.mode(blackColor, BlendMode.srcIn),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: storeProvider.selectedTab == index
                        ? mainColor
                        : blackColor,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
