import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/widgets/Recycled/comment.dart';
import 'package:yugen/widgets/Recycled/commentbox.dart';
import 'package:yugen/widgets/avatar.dart';

/// Tab that shows all comments of the manga/anime
class CommentsTab extends StatefulWidget {
  final String _title, _lang, _collectionName;
  const CommentsTab(
      {super.key,
      required String lang,
      required String title,
      required String collectionName})
      : _collectionName = collectionName,
        _lang = lang,
        _title = title;

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final TextEditingController _textEditingControllerComment =
      TextEditingController();

  final FocusNode _myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _myFocusNode.dispose();
    _textEditingControllerComment.dispose();
    super.dispose();
  }

  /// Method to send a comment once finished writing it
  void _sendComment(String comment) async {
    try {
      var docRef = _database
          .collection(widget._collectionName)
          .doc("${widget._title}(${widget._lang.toLowerCase()})")
          .collection("Comments");
      docRef.doc().set({
        "uid": Auth().getUser()!.uid,
        "username": Auth().getUser()!.displayName,
        "profilepic": Auth().getUser()!.photoURL,
        "comment": comment,
        "date": DateTime.now()
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CommentBox(
          myFocusNode: _myFocusNode,
          onCancel: () {},
          controller: _textEditingControllerComment,
          image: getAvatar(ScreenScaler().getTextSize(8),
              ScreenScaler().getTextSize(9), Colors.deepPurple, context),
          onSend: (comment) {
            _sendComment(comment);
            _myFocusNode.unfocus();
            setState(() {});
          },
        ),
        Expanded(
          child: SizedBox(
              width: Get.width,
              child: Comment(
                title: widget._title,
                lang: widget._lang,
                collectionName: widget._collectionName,
              )),
        ),
      ],
    );
  }
}
