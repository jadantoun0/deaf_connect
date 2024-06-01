import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<bool> doorbellNotifier = ValueNotifier(false);
  final ValueNotifier<bool> telephoneNotifier = ValueNotifier(false);
  final ValueNotifier<bool> alarmNotifier = ValueNotifier(false);
  final ValueNotifier<bool> vibrateNotifier = ValueNotifier(false);
  final ValueNotifier<bool> flashNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          _buildButton(
              icon: 'bell.svg',
              title: 'Detect Doorbell',
              valueNotifier: doorbellNotifier),
          _buildButton(
              icon: 'telephone.svg',
              title: 'Detect Telephone Ringing',
              valueNotifier: telephoneNotifier),
          _buildButton(
              icon: 'clock.svg',
              title: 'Detect Alarm',
              valueNotifier: alarmNotifier),
          _buildButton(
              icon: 'vibrate.svg',
              title: 'Vibrate on Detection',
              valueNotifier: vibrateNotifier),
          _buildButton(
            icon: 'flash.svg',
            title: 'Turn on flash on Detection',
            valueNotifier: flashNotifier,
          ),
          ElevatedButton(
            onPressed: () {
              StoreProvider storeProvider =
                  Provider.of<StoreProvider>(context, listen: false);
              storeProvider.setFemale(false);
            },
            child: Text('test'),
          )
        ],
      ),
    );
  }

  Widget _buildButton({
    required String icon,
    required String title,
    required ValueNotifier valueNotifier,
  }) {
    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: lightGray, width: 1)),
          ),
          child: ListTile(
            tileColor: whiteColor,
            leading: SvgPicture.asset('assets/icons/settings/$icon', width: 28),
            title: Text(title),
            trailing: Transform.scale(
              scale: 0.85,
              child: CupertinoSwitch(
                activeColor: mainColor,
                focusColor: mainColor,
                value: valueNotifier.value,
                onChanged: (newValue) {
                  valueNotifier.value = newValue;
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
