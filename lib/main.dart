import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo/firebase_options.dart';
import 'package:todo/pages/home.dart';
import 'package:todo/pages/loading.dart';
import 'package:todo/pages/signin.dart';
import 'package:todo/state/auth_state.dart';
import 'package:todo/state/todo_state.dart';
import 'package:todo/state/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const AuthStateHolder(
      child: UserStateHolder(
        child: TodoStateHolder(
          child: MainApp(),
        ),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: AuthenticationProvider.of(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            return FutureBuilder(
                future: UserStateHolder.of(context).setCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.error != null) {
                    return SignIn(
                      error: snapshot.error,
                    );
                  } else {
                    UserState? userState = UserProvider.of(context);
                    return user == null
                        ? const SignIn()
                        : userState == null
                            ? const Loading(
                                text: "Loading User...",
                              )
                            : MyHomePage(
                                user: userState.name ?? "Friend",
                              );
                  }
                });
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
        ),
      ),
    );
  }
}
