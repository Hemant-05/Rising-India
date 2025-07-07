import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/admin/home/screens/home_screen_a.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/auth/screens/signup_screen.dart';
import 'package:raising_india/models/user_model.dart';
import '../../../comman/bold_text_style.dart';
import '../../user/home/screens/home_screen_u.dart';
import '../widgets/cus_text_field.dart';
import '../bloc/auth_bloc.dart';
import 'forgot_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool isRememberMe = false;

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
  }
  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent, // or any color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => state.user.role == admin? const MainScreenA(): const HomeScreenU()),
            (route) => false,
          );
        } else if (state is UserError) {
          setState(() => _error = state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Log In', style: bold_text_style(AppColour.white)),
                      const SizedBox(height: 10),
                      Text(
                        'Please sign in to your existing account',
                        style: simple_text_style(color: AppColour.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
                    padding: const EdgeInsets.all(22),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          cus_text_field(
                            'EMAIL',
                            _emailController,
                            'example@gmail.com',
                          ),
                          const SizedBox(height: 20),
                          cus_text_field(
                            'PASSWORD',
                            _passwordController,
                            '********',
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isRememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        isRememberMe = value!;
                                      });
                                    },
                                    activeColor: AppColour.primary,
                                    side: MaterialStateBorderSide.resolveWith((states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return BorderSide(color: AppColour.primary); // Checked border color
                                      }
                                      return BorderSide(color: AppColour.lightGrey); // Unchecked border color
                                    }),
                                  ),
                                  Text(
                                    'Remember Me',
                                    style: simple_text_style(
                                      color: AppColour.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPassScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: simple_text_style(
                                    color: AppColour.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_error != null)
                            Text(
                              _error!,
                              style: simple_text_style(color: AppColour.red),
                            ),
                            const SizedBox(height: 20),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              if (state is UserLoading) {
                                return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator(),
                                );
                              }
                              return ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<UserBloc>(context).add(
                                    UserSignIn(
                                      _emailController.text,
                                      _passwordController.text,
                                      isRememberMe,
                                    ),
                                  );
                                },
                                style: elevated_button_style(),
                                child: Text(
                                  'LOG IN',
                                  style: simple_text_style(
                                    color: AppColour.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child : RichText(
                              text: TextSpan(
                                text: 'Don\'t have an account? ',
                                style: simple_text_style(color: AppColour.grey),
                                children: [
                                  TextSpan(
                                    text: 'SIGN UP',
                                    style: simple_text_style(color: AppColour.primary,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
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
