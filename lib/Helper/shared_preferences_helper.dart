import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _kGalaxy = "galaxy";
  static final String _kPuzzle = "puzzle";
  static final String _kCoins = "coins";

  static final String _onboarding = "onboarding";
  static final String _spaceship = "spaceship";

  static Future<int> getSpaceship() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_spaceship) ?? 0;
  }

  static Future<bool> setSpaceship(int spaceship) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_spaceship, spaceship);

  }

  /// ------------------------------------------------------------
  /// Method that returns whether this is the first time the player
  /// uses the app.
  /// ------------------------------------------------------------
  static Future<bool> onboardingMain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_onboarding) == null){
      //Not set -> first time user launches app
      prefs.setBool(_onboarding, false);
      return true;
    }
    return false;
  }

  /// ------------------------------------------------------------
  /// Method that returns whether this player has already seen
  /// this hint
  /// ------------------------------------------------------------
  static Future<bool> hint(String tuto) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_onboarding+tuto) == null){
      //Not set -> first time user launches app
      prefs.setBool(_onboarding+tuto, false);
      return true;
    }
    return false;
  }


  /// ------------------------------------------------------------
  /// Method that returns the index of the last Galaxy unlocked by
  /// the player, 0 if not set
  /// ------------------------------------------------------------
  static Future<int> getGalaxiesUnlocked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_kGalaxy) ?? 0;
  }

  /// -------------------------------------------------------------
  /// Method that saves the index of the last Galaxy unlocked by
  /// the player
  /// -------------------------------------------------------------
  static Future<bool> setGalaxiesUnlocked(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_kGalaxy, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the index of the last puzzle unlocked in
  /// a given Galaxy, 0 if not set
  /// ------------------------------------------------------------
  static Future<int> getPuzzlesUnlocked({int galaxy}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_kPuzzle+galaxy.toString()) ?? 0;
  }

  /// ----------------------------------------------------------------
  /// Method that saves the index of the last puzzle unlocked in a given
  /// Galaxy
  /// ----------------------------------------------------------------
  static Future<bool> setPuzzlesUnlocked(int value, {int galaxy}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_kPuzzle+galaxy.toString(), value);
  }

  /// -------------------------------------------------------------
  /// Method that returns the number of coins amassed by the player,
  /// 0 if not set
  /// -------------------------------------------------------------
  static Future<int> getCoins() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_kCoins) ?? 0;
  }

  /// -------------------------------------------------------------
  /// Method that saves the number of coins amassed by the player
  /// -------------------------------------------------------------
  static Future<bool> setCoins(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int nbCoins = prefs.getInt(_kCoins) ?? 0;
    return prefs.setInt(_kCoins, nbCoins+value);
  }

}

