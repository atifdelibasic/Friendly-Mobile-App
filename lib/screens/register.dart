import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/validator.dart';
import 'package:friendly_mobile_app/providers/auth_provider.dart';
import 'package:friendly_mobile_app/utility/validation_messages.dart';
import 'package:friendly_mobile_app/utility/widgets.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    final TextEditingController controller = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    final GlobalKey<FlutterPwValidatorState> validatorKey =
        GlobalKey<FlutterPwValidatorState>();

    String? _firstName = "";
    String? _lastName = "";
    String? _password = "";
    String? _email = "";

    doRegister() {
      final form = _formKey.currentState;

      if (form!.validate()) {
        form.save();

        // Set the submitting flag to true
        setState(() {
          _isSubmitting = true;
        });

        // auth.loggedInStatus = Status.Authenticating;
        // auth.notify();

        // Future.delayed(loginTime).then((_) {
        //   Navigator.pushReplacementNamed(context, '/login');
        //   auth.loggedInStatus = Status.LoggedIn;
        //   auth.notify();
        // });

       try {
        auth.register(_email, _password, _firstName, _lastName).then((response) {
  setState(() {
    _isSubmitting = false;
  });
  if (response['isSuccess']) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Registration successful!"),
          actions: <Widget>[
            TextButton(
              child: Text("Go to Login"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
    form.reset();
  } else {
    // Display errors in a pop-up modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: response['errors'].map<Widget>((error) {
              return Text(error);
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
});
       } catch(e) {
        print("uhvation error");
setState(() {
    _isSubmitting = false;
  });
       }

      }
    }

    return GestureDetector(
      child: Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),

                    Text(
                        'Register',
                        style: GoogleFonts.montserrat(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.montserrat(),
                        textInputAction: TextInputAction.done,
                        validator: (value) => validateName(value, 'First name'),
                        onSaved: (value) => _firstName = value,
                        decoration: buildInputDecoration("First name", Icons.person),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.montserrat(),
                        validator: (value) => validateName(value, 'Last name'),
                        onSaved: (value) => _lastName = value,
                        decoration: buildInputDecoration("Last name", Icons.person),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                          style: GoogleFonts.montserrat(),
                        validator: validateEmail,
                        decoration: buildInputDecoration("Email", Icons.email_rounded),
                        onChanged: (value) => _email = value,
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                          style: GoogleFonts.montserrat(),
                            obscureText: true,
                            controller: controller,
                            validator: (value) =>
                                value!.isEmpty ? ValidationMessages.passwordRequired : null,
                            onChanged: (value) => _password = value,
                            decoration: buildInputDecoration("Password", Icons.lock_rounded),
                          ),
                          SizedBox(height: 15),
                          FlutterPwValidator(
                            key: validatorKey,
                            controller: controller,
                            minLength: 8,
                            uppercaseCharCount: 2,
                            numericCharCount: 3,
                            specialCharCount: 1,
                            normalCharCount: 3,
                            width: 400,
                            height: 200,
                            onSuccess: () {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text("Password is matched."),
                              //   ),
                              // );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
  onPressed: _isSubmitting ? null : doRegister, // Disable button when submitting
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    padding: EdgeInsets.all(20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_isSubmitting) 
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),

      Text(
        'Create Account',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    ],
  ),
),

                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.montserrat(
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'Log In',
                              style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
