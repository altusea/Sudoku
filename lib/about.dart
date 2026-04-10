import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sudoku/l10n/app_localizations.dart';
import 'package:sudoku/tutorial.dart';
import 'package:sudoku/ways_to_help.dart';

import 'custom_app_bar.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: MediaQuery.of(context).platformBrightness,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: Scaffold(
            body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Align(alignment: Alignment.topLeft, child: makeAppBar(context, "", null)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Column(children: [
                    const SizedBox(height: 25),
                    Text(
                      AppLocalizations.of(context)!.aboutSudoku("Sud💜ku"),
                      textScaler: TextScaler.linear(2.5),
                    ),
                    const SizedBox(height: 25),
                    Text(AppLocalizations.of(context)!.aboutThanks),
                    const SizedBox(height: 20),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                AppLocalizations.of(context)!.aboutVersion(snapshot.data?.version ?? "???"),
                              ),
                            );
                          default:
                            return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    getWaysToHelp(context),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Tutorial()));
                      },
                      child: Text(AppLocalizations.of(context)!.aboutReplayTutorial),
                    ),
                    TextButton(
                      onPressed: () async {
                        final value = await PackageInfo.fromPlatform();
                        if (!context.mounted) return;
                        showLicensePage(
                          context: context,
                          applicationName: "SUD💜KU",
                          applicationVersion: value.version,
                          applicationLegalese: "Licensed under GPLv3",
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.aboutShowLicenses),
                    )
                  ]),
                ),
              ],
            ),
          ),
        )));
  }
}
