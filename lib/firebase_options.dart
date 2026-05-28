// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web; 
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNC5XFoqZN8XPUNb0QNmASu7K6HoYjrAM',
    authDomain: 'nutrismart-90204.firebaseapp.com',
    projectId: 'nutrismart-90204',
    storageBucket: 'nutrismart-90204.firebasestorage.app',
    messagingSenderId: '281591271361',
    appId: '1:281591271361:web:c588517bb70e2de0832940',
  );
}