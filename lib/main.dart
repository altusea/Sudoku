import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/l10n/app_localizations.dart';
import 'package:sudoku/save_manager.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku/tutorial.dart';

import 'home_page.dart';

final _logger = Logger('MainApp');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Future<String> checkFirstSeen() async {
    bool seen = await SaveManager().hasSeenTutorial();

    if (seen) {
      return HomePage.id;
    } else {
      return Tutorial.id;
    }
  }

  Future<ThemeSettings> loadThemeSettings(Brightness brightness) async {
    const defaultColor = Color.fromARGB(0xFF, 0xAA, 0x8E, 0xD6);
    bool customTheme = await SaveManager().isCustomTheme();

    if (customTheme) {
      return ThemeSettings(customTheme, await SaveManager().isDark(), await SaveManager().getPrimaryColor() ?? defaultColor);
    } else {
      return ThemeSettings(customTheme, brightness == Brightness.dark, await DynamicColorPlugin.getAccentColor() ?? defaultColor);
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return FutureBuilder(
      future: Future.wait([checkFirstSeen(), loadThemeSettings(brightness)]),
      builder: (context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          _logger.severe("Error loading app", snapshot.error, snapshot.stackTrace);
        }

        final initialRoute = snapshot.data![0] as String;
        final themeSettings = snapshot.data![1] as ThemeSettings;

        return ChangeNotifierProvider(
            create: (context) => ThemeProvider(themeSettings),
            child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Sudoku',
                theme: ThemeData(colorScheme: themeProvider.lightScheme),
                darkTheme: ThemeData(colorScheme: themeProvider.darkScheme),
                themeMode: themeProvider.themeMode,
                initialRoute: initialRoute,
                routes: {
                  HomePage.id: (context) => const HomePage(),
                  Tutorial.id: (context) => const Tutorial(),
                },
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            }));
      },
    );
  }
}
