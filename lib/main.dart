import 'package:flutter/material.dart';
import 'dbHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveBoard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(title: 'LiveBoard Login Page'),
    );
  }
}

  
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLoginPressed() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    // Get user from database
    final user = await DatabaseHelper.instance.getUserByUsername(username);

    // Validate login
    if (user != null && user.password == password) {
      // Navigate to home page if login is successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Show error message if login fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login failed'),
            content: const Text('Invalid username or password.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onLoginPressed(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  AuthStatus _loginState = AuthStatus.emailAddress;
  AuthStatus get signOnState => _loginState;

  String? _email;
  String? get email => _email;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );


    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = AuthStatus.signedIn;
      } else {
        _loginState = AuthStatus.emailAddress;
      }
      notifyListeners();
    });
  }

  Future<void> checkEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = AuthStatus.password;
      } else {
        _loginState = AuthStatus.registration;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signOn(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelSignUp() {
    _loginState = AuthStatus.emailAddress;
    notifyListeners();
  }

  Future<void> signUp(String email, String displayName, String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}