import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _password =new TextEditingController();
  TextEditingController _passwordLogin =new TextEditingController();

  TextEditingController _email = new TextEditingController();



  Future<FirebaseApp> _initializeFirebase() async{
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }


  @override
  Widget build(BuildContext context) {
   final user = Provider.of<AuthRepository>(context);
    return Scaffold(
        appBar: AppBar(title: Text('Login'),centerTitle:true),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
               return LoginScreen();
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        )
    );
  }

  Widget LoginScreen(){

    final user = Provider.of<AuthRepository>(context);
    return SingleChildScrollView(
      child: Center(
          child: SizedBox(
            width: 350,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                const Text(
                    'Welcome to Startup Names Generator, please log in below'
                    ,style: TextStyle(fontSize: 17,color: Colors.black)
                ),
                const SizedBox(height: 20),
                Padding(
                  //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'mzareeb99@hotmail.com'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password'),
                  ),
                ),

                const Text(''),
                user.status==Status.Authenticating ? const Center(
                  child: CircularProgressIndicator(),
                ) :
                Container(
                  height: 40,
                  width: 350,
                  child: TextButton(
                    child: const Text('Log in',style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    onPressed: () async {
                      await user.signIn(_email.text, _password.text);
                      if(user.isAuthenticated) {
                        Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Successfully Log in'),
                      backgroundColor: Colors.deepPurple,
                      ));
                      }else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'There was an error logging into the app')));
                      }
                      },
                  ),

                  decoration: BoxDecoration(
                      color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)

                  ),
                ),
                const Text(''),
                Container(
                  height: 40,
                  width: 350,
                  child: TextButton(
                    child: const Text('New user? Click to sign up',style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    onPressed: () async {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            color: Colors.white,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        'Please confirm your password below:',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                                    child:
                                    TextField(
                                      controller: _passwordLogin,
                                      obscureText: true,
                                      //resizeToAvoidBottomInset: true,
                                      decoration: const InputDecoration(
                                          labelText: 'Password',
                                          hintText: 'Enter your password'),
                                    ),
                                  ),
                                  ElevatedButton(
                                      child: Container(child: Text('Confirm'),
                                        decoration: BoxDecoration(
                                            color: Colors.lightBlue, borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),

                                      onPressed: () async {
                                        _password.text ==_passwordLogin.text && _password.text !='' && _passwordLogin.text !=''? {
                                        await user.signUp(_email.text,_password.text),
                                        setState(() {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text('Successfully register'),
                                            backgroundColor: Colors.deepPurple,
                                          ));
                                        }),
                                      } : {
                                          setState(() {
                                            Navigator.pop(context);
                                          }),
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text(('Passwords must match'))))
                                        };
                                      }
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      },
                  ),

                  decoration: BoxDecoration(
                      color: Colors.lightBlue, borderRadius: BorderRadius.circular(20)

                  ),
                ),
              ],
            ),
          )
      ),
    );
  }


}