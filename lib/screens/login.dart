import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/validator.dart';
import 'package:friendly_mobile_app/utility/widgets.dart';
import 'package:friendly_mobile_app/providers/auth_provider.dart';
import 'package:friendly_mobile_app/providers/user_provider.dart';
import 'package:friendly_mobile_app/utility/validation_messages.dart';
import 'package:friendly_mobile_app/domain/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _email = "";
  String? _password = "";
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    doLogin() async {
      final form = _formKey.currentState;
      if (form!.validate()) {
        form.save();

        setState(() {
          _isSubmitting = true;
        });

        try {
          Map<String, dynamic> response = await auth.login(_email, _password);

          if (response['status']) {
            User user = response['user'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            setState(() {
              _isSubmitting = false;
            });

            Navigator.pushReplacementNamed(context, '/feed');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred $error'),
              duration: Duration(seconds: 5),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: !isKeyboardOpen,
                  child: Icon(
                    Icons.person_pin_circle_sharp,
                    size: 100,
                  ),
                ),
                SizedBox(
                  height: 55,
                ),
                Text(
                  'Hello Again!',
                  style: GoogleFonts.montserrat(
                      fontSize: 30, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Login to continue.',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormField(
                    style: GoogleFonts.montserrat(),
                    autofocus: false,
                    validator: validateEmail,
                    onSaved: (value) => _email = value,
                    decoration:
                        buildInputDecoration("Email", Icons.email_rounded),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormField(
                    style: GoogleFonts.montserrat(),
                    obscureText: !_isPasswordVisible,
                    autofocus: false,
                    validator: (value) => value!.isEmpty
                        ? ValidationMessages.passwordRequired
                        : null,
                    onSaved: (value) => _password = value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Log In',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Not a member?', style: GoogleFonts.montserrat()),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: Text(
                        'Register now',
                        style: GoogleFonts.montserrat(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
