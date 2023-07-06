import 'package:communitysupport/routes.dart';
import 'package:communitysupport/services/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:communitysupport/services/models.dart';
import 'package:communitysupport/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserDataProvider(),
      child: const App(),
    ),
  );
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors

        if (snapshot.hasError) {
          if (kDebugMode) {
            print(snapshot.error?.toString());
          }
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Text('Error: ${snapshot.error?.toString()}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          // FirebaseApi().initNotifications();
          // FirebaseApi().initLocalNotifications();

          return StreamProvider(
            create: (_) => FirestoreService().streamReport(),
            initialData: Report(),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              theme: appTheme,
              routes: appRoutes,
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Text("loading"),
          ),
        );
      },
    );
  }
}

class PermissionRequester extends StatefulWidget {
  const PermissionRequester({super.key});

  @override
  PermissionRequesterState createState() => PermissionRequesterState();
}

class PermissionRequesterState extends State<PermissionRequester> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  _requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.status;

    if (permissionStatus.isDenied) {
      permissionStatus = await Permission.locationWhenInUse.request();
      if (permissionStatus.isDenied) {
        if (kDebugMode) {
          print("User denied location permission.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Replace with your own widget
  }
}
