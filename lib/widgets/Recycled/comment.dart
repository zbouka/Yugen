import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:yugen/widgets/Recycled/comment_functions.dart';
import '../../assets/loading.dart';
import '../../screens/auth/auth.dart';
import 'commentbox.dart';
import 'comment_reply.dart';

/// Class for the message with the text, data, profile picture, likes and the posibility to delete the comment
class Comment extends StatefulWidget {
  final String title, lang, collectionName;
  static bool pressedReply = false;
  static String docID = "";
  const Comment(
      {super.key,
      required this.title,
      required this.lang,
      required this.collectionName});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  late final FocusNode _myFocusNode = FocusNode();
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final TextEditingController _textEditingControllerReply =
      TextEditingController();
  late Stream<QuerySnapshot<Map<String, dynamic>>> comments;

  @override
  void initState() {
    super.initState();
    comments = getComments(
        database: _database,
        collectionName: widget.collectionName,
        isReply: false,
        lang: widget.lang,
        title: widget.title);
  }

  @override
  void dispose() {
    _myFocusNode.dispose();
    _textEditingControllerReply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: comments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              "noComments".tr,
              style: TextStyle(fontSize: ScreenScaler().getTextSize(8)),
            ));
          } else {
            return ListView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];

                return Column(children: [
                  Column(
                    children: [
                      showComment(
                          collectionName: widget.collectionName,
                          profilePic: doc["profilepic"],
                          userName: doc["username"],
                          date: doc["date"],
                          commentID: doc.id,
                          data: doc.data() as Map<String, dynamic>,
                          database: _database,
                          isReply: false,
                          lang: widget.lang,
                          likes: (doc.data() as Map<String, dynamic>)
                                  .containsKey("likes")
                              ? doc["likes"]
                              : null,
                          title: widget.title,
                          uid: doc["uid"],
                          comment: doc["comment"]),
                      Visibility(
                        visible:
                            Comment.pressedReply && doc.id == Comment.docID,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: CommentBox(
                            controller: _textEditingControllerReply,
                            myFocusNode: _myFocusNode,
                            onCancel: () {
                              setState(() {
                                Comment.pressedReply = false;
                              });
                            },
                            image: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.purple,
                              child: CircleAvatar(
                                radius: 17,
                                backgroundImage: Image.network(
                                  Auth().getUser()!.photoURL!,
                                  height: 64,
                                  width: 64,
                                ).image,
                              ),
                            ),
                            onSend: (comment) {
                              sendReplyComment(
                                comment: comment,
                                commentID: Comment.docID,
                                collectionName: widget.collectionName,
                                database: _database,
                                lang: widget.lang,
                                title: widget.title,
                              );
                              setState(() {
                                Comment.pressedReply = true;
                              });
                              _textEditingControllerReply.clear();
                              _myFocusNode.unfocus();
                              setState(() {
                                Comment.pressedReply = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Reply(
                      commentID: doc.id,
                      doc: doc,
                      collectionName: widget.collectionName,
                      title: widget.title,
                      lang: widget.lang),
                ]);
              },
            );
          }
        });
  }
}
