import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:scoped_model/scoped_model.dart';
import 'chat_model.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class Chat extends StatefulWidget {
  final String uid;
  Chat({this.uid});
  @override
  ChatState createState() {
    return new ChatState();
  }
}

class ChatState extends State<Chat> {
  final controller = TextEditingController();
  final scrollcontroller = ScrollController();
  final ConnectModel connectmodel = ConnectModel();
  var connect = Connectivity();
  StreamSubscription<ConnectivityResult> _streamSubscription1;
  @override
  void initState() {
    _streamSubscription1 =
        connect.onConnectivityChanged.listen((ConnectivityResult result) {
      (result == ConnectivityResult.none)
          ? connectmodel.change()
          : connectmodel.data();
    });
    super.initState();
  }

  myalert(msg, time, sender) {
    var temp = int.parse(time);
    var date = new DateTime.fromMillisecondsSinceEpoch(temp);

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text("Message Details"),
              content: Container(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Message : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 220,
                            child: Text(
                              msg,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "from : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          (sender == "chaitu") ? Text("Mahesh") : Text("Mouni")
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Time : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(date.toString()),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  void dispose() {
    _streamSubscription1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ConnectModel>(
      model: connectmodel,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: GradientAppBar(
          title: Text("Chat room for Chaitu & Mouni"),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  //Chat base
                  Expanded(child: buildListview()),

                  //Input text field
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 10),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: controller,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 1),
                          ),
                          fillColor: Colors.red,
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(10.0)),
                          hintText: "ur message here",
                          suffixIcon: ScopedModelDescendant<ConnectModel>(
                            builder: (context, _, connectmodel) {
                              return (connectmodel.connect1 !=
                                      "ConnectivityResult.none")
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        sendmessege();
                                        scrollcontroller.animateTo(0.0,
                                            curve: Curves.bounceOut,
                                            duration:
                                                Duration(milliseconds: 400));
                                      })
                                  : SizedBox(
                                      height: 1,
                                      width: 1,
                                    );
                            },
                          )),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListview() {
    var cf = Firestore.instance.collection("chats").reference();
    return StreamBuilder<QuerySnapshot>(
      stream: cf
          .orderBy('timestamp_client', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
            break;
          default:
            if (snapshot.hasError) {
              return Center(
                child: Text("went on error"),
              );
            } else {
              return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: scrollcontroller,
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) =>
                      buildmesseges(index, snapshot.data.documents[index]));
            }
        }
      },
    );
  }

  Widget buildmesseges(int index, DocumentSnapshot ds) {
    return (ds['senderid'] == "chaitu")

        //Mahesh messages
        ? Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => myalert(
                  ds['content'], ds['timestamp_client'], ds['senderid']),
              child: Container(
                  margin: EdgeInsets.only(
                      left: (MediaQuery.of(context).size.width) * 0.25,
                      right: 10,
                      top: 8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: RichText(
                      textAlign: TextAlign.end,
                      softWrap: true,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: ds['content'],
                              style: TextStyle(fontSize: 18)),
                        ],
                      ))),
            ))

        //Mouni messages
        : Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => myalert(
                  ds['content'], ds['timestamp_client'], ds['senderid']),
              child: Card(
                color: Colors.white10,
                margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.25,
                    bottom: 10,
                    left: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(5)),
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    ds['content'],
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ));
  }

  void sendmessege() {
    if (controller.text.isNotEmpty) {
      DocumentReference df = Firestore.instance
          .collection('chats')
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      df.setData({
        'content': controller.text.trim(),
        'senderid': "chaitu",
        'timestamp_client': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp_server': FieldValue.serverTimestamp()
      }).then((onValue) {
        print("sent successfullyyyy.......................");
      });
      controller.clear();
    } else {
      Fluttertoast.showToast(
          msg: "Write Something..!",
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          timeInSecForIos: 1,
          gravity: ToastGravity.BOTTOM);
    }
  }
}
