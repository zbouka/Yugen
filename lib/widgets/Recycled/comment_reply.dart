import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/widgets/Recycled/comment_functions.dart';

/// Class for the reply message with the text, data, profile picture, likes and the posibility to delete the comment
class Reply extends StatefulWidget {
  final DocumentSnapshot doc;
  final String title, lang;
  final String commentID;
  final String collectionName;
  const Reply(
      {super.key,
      required this.doc,
      required this.title,
      required this.lang,
      required this.collectionName,
      required this.commentID});

  @override
  State<Reply> createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
  bool _pressedShowReplies = false;

  final FirebaseFirestore _database = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getComments(
            database: _database,
            collectionName: widget.collectionName,
            commentID: widget.commentID,
            isReply: true,
            lang: widget.lang,
            title: widget.title),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return Column(
              children: [
                Center(
                  child: Visibility(
                    visible: snapshot.data!.docs.isNotEmpty ? true : false,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _pressedShowReplies = !_pressedShowReplies;
                        });
                      },
                      icon: _pressedShowReplies
                          ? const Icon(Ionicons.arrow_up_circle_outline)
                          : const Icon(Ionicons.arrow_down_circle_outline),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data!.docs.isNotEmpty &&
                          _pressedShowReplies == true
                      ? true
                      : false,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];

                        return Padding(
                            padding: const EdgeInsets.only(left: 50.0),
                            child: Column(
                              children: [
                                showComment(
                                    collectionName: widget.collectionName,
                                    profilePic: doc["profilepic"],
                                    userName: doc["username"],
                                    date: doc["date"],
                                    commentID: widget.commentID,
                                    data: doc.data() as Map<String, dynamic>,
                                    database: _database,
                                    isReply: true,
                                    lang: widget.lang,
                                    likes: (doc.data() as Map<String, dynamic>)
                                            .containsKey("likes")
                                        ? doc["likes"]
                                        : null,
                                    title: widget.title,
                                    uid: doc["uid"],
                                    replyID: doc.id,
                                    comment: doc["comment"]),
                              ],
                            ));
                      }),
                ),
              ],
            );
          }
        });
  }
}
