import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_me/Login.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_repository.dart';
import 'package:flutter/foundation.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}
class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
            body: Center(
                child: Text(snapshot.error.toString(),
                    textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return ChangeNotifierProvider(
            create: (context) => AuthRepository.instance(),
          child: const MyApp()
          );
      }
      return const Center(child: CircularProgressIndicator());
        },
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}
class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];                 // NEW
  var _saved = <WordPair>{};     // NEW
  final _biggerFont = const TextStyle(fontSize: 20); // NEW
  SnappingSheetController _snappingSheetController = SnappingSheetController();
  bool drag = false;
  var user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthRepository>(context);
    return Scaffold (
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
    !user.isAuthenticated ?
          IconButton(
            icon: const Icon(Icons.login),
           onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Login()));},
           tooltip: 'Login',
          )
     :
       IconButton(
         icon: const Icon(Icons.exit_to_app),
         onPressed: () {
           user.signOut();
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
             content: Text('Successfully logged out'),
             backgroundColor: Colors.deepPurple,
           ));
           },
         tooltip: 'Logout',
       ),

        ],
      ),
        body: GestureDetector(
          child: SnappingSheet(
            controller: _snappingSheetController,
            snappingPositions: const [
              SnappingPosition.pixels(
                  positionPixels: 220,
                  snappingCurve: Curves.bounceOut,
                  snappingDuration: Duration(milliseconds: 350)),
              SnappingPosition.factor(
                  positionFactor: 1.1,
                  snappingCurve: Curves.easeInBack,
                  snappingDuration: Duration(milliseconds: 2)),
            ],
            lockOverflowDrag: true,
            onSnapCompleted: _onCompleted,
            initialSnappingPosition:
            SnappingPosition.factor(positionFactor: 0.074),
            child: _buildSuggestions(),
            sheetBelow: user.isAuthenticated
                ? SnappingSheetContent(
              draggable: drag,
              child: Container(
                color: Colors.white,
                child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Column(children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                color: Colors.grey,
                                height: 50,
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                              EdgeInsets.all(10.0),
                                              child: Center(
                                                child: Text(
                                                    "Welcome back, " +
                                                        user
                                                            .getUserEmail(),
                                                    style: const TextStyle(
                                                        fontSize: 14.0)),
                                              ),
                                            ),
                                          ],
                                        )),
                                    const IconButton(
                                      icon: Icon(Icons.keyboard_arrow_up),
                                      onPressed: null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        Row(children: <Widget>[
                          FutureBuilder(
                            future: user.getDownloadUrl(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              return Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: snapshot.data != null
                                      ? NetworkImage(snapshot.data!)
                                      : null,
                                ),
                              );
                            },
                          ),
                          Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(user.getUserEmail(),
                                  style: const TextStyle(fontSize: 18))),
                        ]),
                        Row(
                            children:<Widget>[
                              MaterialButton(
                              onPressed: () async {
                                FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'png',
                                    'jpg',
                                    'gif',
                                    'bmp',
                                    'jpeg',
                                    'webp'
                                  ],
                                );
                                File file;
                                if (result != null) {
                                  file = File(result.files.single.path!);
                                  user.uploadImage(file);
                                }else{
                                  const snackbar = SnackBar(
                                    content: Text('No image selected'),
                                    backgroundColor: Colors.deepPurple,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                }
                              },
                              textColor: Colors.white,
                              padding: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                ),
                                padding: const EdgeInsets.all(5.0),
                                child: const Text('Change Avatar',
                                    style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            ]
                        ),
                      ]),
                    ]),
              ),
              //heightBehavior: SnappingSheetHeight.fit(),
            )
                : null,
          ),
          onTap: () => {
            setState(() {
              if (drag == false) {
                drag = true;

                _snappingSheetController.snapToPosition(const SnappingPosition.factor(
                  positionFactor: 0.37,
                  snappingDuration: Duration(milliseconds: 500),
                ));
              } else {
                drag = false;
                _snappingSheetController.snapToPosition(const SnappingPosition.factor(
                    positionFactor: 0.074,
                    snappingCurve: Curves.easeInBack,
                    snappingDuration: Duration(milliseconds: 300)));
              }
            })
          },
        ));
  }

  dynamic _onCompleted(_data, SnappingPosition _position) {
    if (drag == true) {
      _snappingSheetController.stopCurrentSnapping();
      _snappingSheetController.snapToPosition(const SnappingPosition.factor(
          positionFactor: 0.37, snappingCurve: Curves.easeInBack));
    } else {
      _snappingSheetController.snapToPosition(const SnappingPosition.factor(
          positionFactor: 0.074,
          snappingCurve: Curves.easeInBack,
          snappingDuration: Duration(milliseconds: 30)));
    }
  }


  Widget _profile() {


    return const Text('hello');
  }

  static Future<User?> signInUsingEmailPassword({required String email, required String password, required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
    }

    return user;
  }


  void _pushToCloud(WordPair pair) async{
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    if(user.isAuthenticated){
            await _firestore.collection('data').doc(AuthRepository.instance().user?.uid).collection('Favorite')
                .doc(pair.toString()).set({'first' : pair.first.toString() , 'second' : pair.second.toString()});
        }
    //notifyListeners();
  }




  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final user = Provider.of<AuthRepository>(context);
          var fav = _saved;
          AuthRepository.instance().isAuthenticated ? fav = user.favourites
          : fav = _saved;
          final tiles = fav.map(
                (pair) {
                  return Dismissible(
                    key: ValueKey<WordPair>(pair),
                    child: ListTile(
                        title: Text(
                          pair.asPascalCase,
                          style: _biggerFont,
                        )),
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      color: Colors.deepPurple,
                      alignment: Alignment.centerLeft,
                      child: Row(children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Delete Suggestion',
                            style: TextStyle(color: Colors.white))
                      ]),
                    ),
                    onDismissed: (direction){
                      setState(() {
                        user.removePair(pair);
                        _saved.remove(pair);
                      });
                      var str = pair.asPascalCase;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content:
                          Text('${pair.asPascalCase} deleted from Favorite'),
                        duration: const Duration(milliseconds: 600),
                        backgroundColor: Colors.redAccent,
                      )
                      );
                    },
                    confirmDismiss: (DismissDirection direction) async {
                      final deletion = pair.asPascalCase;

                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text("Delete Suggestion"),
                              content: Text(
                                  "are you sure you want to delete ${deletion} from your saved suggestions?"),
                              actions: <Widget>[
                                ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                           "Yes",
                          style: TextStyle(
                          color: Colors.white,
                          ),
                          ),
                          style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                          )),
                          ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                          "No",
                          style: TextStyle(
                          color: Colors.white,
                          ),
                          ),
                          style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                          )),
                          ],
                          );
                        },
                      );
                    },
                  );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
         // generateWordPairs().take(10).toList();
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair) ||
        (user.isAuthenticated && user.favourites.contains(pair));  // NEW
  final uploaded = user.isAuthenticated && user.favourites.contains(pair);
  final local = _saved.contains(pair);
  if(!uploaded && local)  user.addPair(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),trailing: Icon(
      alreadySaved ? Icons.star : Icons.star_border,
      color: alreadySaved ? Colors.deepPurple : null,
      semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
    ),
      onTap: () {      // NEW lines from here...
      setState(() {
        if (alreadySaved) {
          _saved.remove(pair);
          user.removePair(pair);
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content:
          // Text('${pair.asPascalCase} deleted from Favorite'),
          // duration: const Duration(milliseconds: 600),
          //   backgroundColor: Colors.redAccent,
          // )
          // );
        } else {
          _saved.add(pair);
          user.addPair(pair);
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content:
          // Text('${pair.asPascalCase} added to Favorite'),
          //   duration: const Duration(milliseconds: 600),
          //     backgroundColor: Colors.green,
          // )
          // );
        }
      });
    },
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator',
      home: RandomWords(),
      theme: ThemeData(          // Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}