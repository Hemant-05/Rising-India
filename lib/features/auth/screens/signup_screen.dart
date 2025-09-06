import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/auth/screens/verification_screen.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import '../../../comman/bold_text_style.dart';
import '../../../constant/ConString.dart';
import '../../admin/home/screens/home_screen_a.dart';
import '../../user/home/screens/home_screen_u.dart';
import '../widgets/cus_text_field.dart';
import '../../../constant/ConPath.dart';
import '../../../models/user_model.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = user;
  String? _error;

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationCodeScreen(
                role : _role
              ),
            ),
          );
        } else if (state is UserError) {
          setState(() => _error = state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColour.background,
        body: Stack(
          children: [
            Align(
              alignment: Alignment(-2.5, -1.4),
              child: SvgPicture.asset(
                back_vector_svg,
                color: AppColour.lightGrey.withOpacity(0.2),
                height: 250,
                width: 250,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            margin: const EdgeInsets.only(top: 20, left: 20),
                            decoration: BoxDecoration(
                              color: AppColour.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                size: 16,
                                Icons.arrow_back_ios_rounded,
                                color: AppColour.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Sign Up',
                            style: bold_text_style(AppColour.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Please sign up to get started',
                            style: simple_text_style(color: AppColour.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColour.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children:[
                          const SizedBox(height: 20,),
                          cus_text_field(
                            label: 'NAME',
                            controller: _nameController,
                            hintText: 'Hemant sahu',
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'EMAIL',
                            controller: _emailController,
                            hintText: 'example@gmail.com',
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'PASSWORD',
                            controller: _passwordController,
                            hintText: '********',
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'CONFIRM PASSWORD',
                            controller: _confirmPasswordController,
                            hintText: '********',
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          if (_error != null)
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColour.red.withOpacity(0.1),
                                border: Border.all(color: AppColour.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _error!,
                                style: simple_text_style(
                                  color: AppColour.red,
                                ),
                              ),
                            ),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                style: elevated_button_style(),
                                onPressed: () {
                                  var email = _emailController.text.trim();
                                  if (email.split('#').first.toLowerCase() ==
                                      'admin') {
                                    _role = admin;
                                  } else {
                                    _role = user;
                                  }
                                  BlocProvider.of<UserBloc>(context).add(
                                    UserSignUp(
                                      name: _nameController.text,
                                      email: email.split('#').last,
                                      password: _passwordController.text,
                                      confirmPassword:
                                          _confirmPasswordController.text,
                                      role: _role,
                                    ),
                                  );
                                },
                                child: state is UserLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppColour.white,
                                        ),
                                      )
                                    : Text(
                                        'CREATE ACCOUNT',
                                        style: simple_text_style(
                                          color: AppColour.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
