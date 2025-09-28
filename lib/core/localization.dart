 import 'package:flutter_localization/flutter_localization.dart';

 // String keys for the app's translations. Keep keys centralized for consistency.
 class L10nKeys {
   static const appTitle = 'app.title';
   static const homeTitle = 'home.title';
   static const settingsTitle = 'settings.title';
   static const cartTitle = 'cart.title';
   static const checkoutTitle = 'checkout.title';
 }

 // English strings
 const Map<String, dynamic> _en = <String, dynamic>{
   L10nKeys.appTitle: 'YASA Commerce',
   L10nKeys.homeTitle: 'Home',
   L10nKeys.settingsTitle: 'Settings',
   L10nKeys.cartTitle: 'Cart',
   L10nKeys.checkoutTitle: 'Checkout',
 };

 // Arabic strings
 const Map<String, dynamic> _ar = <String, dynamic>{
   L10nKeys.appTitle: 'التجارة MVC',
   L10nKeys.homeTitle: 'الرئيسية',
   L10nKeys.settingsTitle: 'الإعدادات',
   L10nKeys.cartTitle: 'السلة',
   L10nKeys.checkoutTitle: 'الدفع',
 };

 // Expose the list of supported map locales for initialization in main.dart
 final List<MapLocale> kAppLocales = <MapLocale>[
   const MapLocale('en', _en),
   const MapLocale('ar', _ar),
 ];

