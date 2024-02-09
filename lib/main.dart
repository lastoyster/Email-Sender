import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:send_email_example/api/google_auth_api.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Email In Background';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
          centerTitle: true,
        ),
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(20),
              textStyle: TextStyle(fontSize: 24),
            ),
            child: Text('Send Email'),
            onPressed: sendEmail,
          ),
        ),
      );

  Future sendEmail() async {
    final user = await GoogleAuthApi.signIn();

    if (user == null) return;

    final email = user.email;
    final auth = await user.authentication;
    final token = auth.accessToken!;

    print('Authenticated: $email');

    // Optiontally signout
    // GoogleAuthApi.signOut();

    final smtpServer = gmailSaslXoauth2(email, token);
    final message = Message()
      ..from = Address(email, 'PratikshaK')
      ..recipients = ['kadampratiksha56@gmail.com']
      ..subject = 'Hello Pratiksha'
      ..text = 'This is a email without any backend!';
    // ..html =
    //     '<h1>Test</h1>\n<p>Hey! Here is some HTML content</p><img src="cid:myimg@3.141"/>';

    try {
      await send(message, smtpServer);

      showSnackBar('Sent email successfully!');
    } on MailerException catch (e) {
      print('Send Email: $e');
    }
  }

  void showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      backgroundColor: Colors.green,
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
