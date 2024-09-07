import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/widgets/Recycled/comment.dart';

/// Gets all the reply messages from the specific manga/anime
Stream<QuerySnapshot<Map<String, dynamic>>> getComments({
  required FirebaseFirestore database,
  required String collectionName,
  required String title,
  required String lang,
  String? commentID,
  required bool isReply,
}) {
  return isReply
      ? database
          .collection(collectionName)
          .doc("$title(${lang.toLowerCase()})")
          .collection("Comments")
          .doc(commentID)
          .collection("Replies")
          .orderBy("date", descending: false)
          .snapshots()
      : database
          .collection(collectionName)
          .doc("$title(${lang.toLowerCase()})")
          .collection("Comments")
          .orderBy("date", descending: true)
          .snapshots();
}

/// Method to delete a comment whenever is a reply or comment
Future deleteComment({
  required FirebaseFirestore database,
  String? replyID,
  required String collectionName,
  required String title,
  required String lang,
  required String commentID,
  required bool isReply,
}) async {
  try {
    isReply
        ? await database
            .collection(collectionName)
            .doc("$title(${lang.toLowerCase()})")
            .collection("Comments")
            .doc(commentID)
            .collection("Replies")
            .doc(replyID)
            .delete()
        : await database
            .collection(collectionName)
            .doc("$title(${lang.toLowerCase()})")
            .collection("Comments")
            .doc(commentID)
            .delete();
  } catch (e) {
    return false;
  }
}

/// Method to update whenever the comment is liked or not
void updateLikes({
  required String commentID,
  required bool liked,
  required FirebaseFirestore database,
  String? replyID,
  required String collectionName,
  required String title,
  required String lang,
  required bool isReply,
}) {
  try {
    var docRef = isReply
        ? database
            .collection(collectionName)
            .doc("$title(${lang.toLowerCase()})")
            .collection("Comments")
            .doc(commentID)
            .collection("Replies")
            .doc(replyID)
        : database
            .collection(collectionName)
            .doc("$title(${lang.toLowerCase()})")
            .collection("Comments")
            .doc(commentID);
    if (!liked) {
      docRef.set({
        "likes": FieldValue.arrayUnion([Auth().getUser()!.uid]),
      }, SetOptions(merge: true));
    } else {
      docRef.update({
        "likes": FieldValue.arrayRemove([Auth().getUser()!.uid]),
      });
    }
  } catch (e) {
    sendErrorMail(false, "ERROR", e);
  }
}

/// Method to send a reply to a comment
void sendReplyComment({
  required String comment,
  required String commentID,
  required FirebaseFirestore database,
  required String collectionName,
  required String title,
  required String lang,
}) {
  try {
    var docRef = database
        .collection(collectionName)
        .doc("$title(${lang.toLowerCase()})")
        .collection("Comments")
        .doc(commentID)
        .collection("Replies");

    docRef.doc().set({
      "uid": Auth().getUser()!.uid,
      "username": Auth().getUser()!.displayName,
      "profilepic": Auth().getUser()!.photoURL,
      "comment": comment,
      "date": DateTime.now()
    }, SetOptions(merge: true));
  } catch (e) {
    sendErrorMail(false, "ERROR", e);
  }
}

Widget showComment(
    {required String profilePic,
    required String userName,
    required String comment,
    required Timestamp date,
    required String uid,
    String? commentID,
    String? replyID,
    required FirebaseFirestore database,
    required String collectionName,
    required String title,
    required String lang,
    required Map<String, dynamic> data,
    List? likes,
    required bool isReply}) {
  return Card(
    elevation: 6,
    margin: const EdgeInsets.all(10),
    child: Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.purple,
            child: CircleAvatar(
              radius: 17,
              backgroundImage: Image.network(
                profilePic,
                height: 64,
                width: 64,
              ).image,
            ),
          ),
          title: Text(userName),
          subtitle: ReadMoreText(
            comment,
            trimLines: 3,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'showMore'.tr,
            trimExpandedText: 'showLess'.tr,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "${(date).toDate().day}/${(date).toDate().month}/${(date).toDate().year}",
              ),
              const SizedBox(
                width: 3,
              ),
              Visibility(
                visible: uid == Auth().getUser()!.uid ? true : false,
                child: GestureDetector(
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    Get.defaultDialog(
                      confirm: TextButton(
                          onPressed: () async {
                            isReply
                                ? await deleteComment(
                                    isReply: true,
                                    collectionName: collectionName,
                                    commentID: commentID!,
                                    lang: lang,
                                    title: title,
                                    database: database,
                                    replyID: replyID)
                                : await deleteComment(
                                    isReply: false,
                                    collectionName: collectionName,
                                    commentID: commentID!,
                                    lang: lang,
                                    title: title,
                                    database: database,
                                  );
                            Get.forceAppUpdate();
                            Get.back();
                          },
                          child: Text("confirm".tr)),
                      cancel: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text("cancel".tr)),
                      title: "confirmDelete".tr,
                      middleText: "deleteText".tr,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            LikeButton(
              circleColor: const CircleColor(
                  start: Color(0xff00ddff), end: Color(0xff0099cc)),
              bubblesColor: const BubblesColor(
                dotPrimaryColor: Color(0xff33b5e5),
                dotSecondaryColor: Color(0xff0099cc),
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  Icons.thumb_up_alt,
                  color: isLiked ? Colors.green : Colors.grey,
                );
              },
              isLiked: data.containsKey("likes")
                  ? likes!.contains(Auth().getUser()!.uid)
                  : false,
              onTap: (isLiked) async {
                isReply
                    ? updateLikes(
                        collectionName: collectionName,
                        database: database,
                        isReply: true,
                        lang: lang,
                        title: title,
                        commentID: commentID!,
                        replyID: replyID,
                        liked: isLiked)
                    : updateLikes(
                        collectionName: collectionName,
                        database: database,
                        isReply: false,
                        lang: lang,
                        title: title,
                        commentID: commentID!,
                        liked: isLiked);
                return !isLiked;
              },
              likeCount: data.containsKey("likes") ? likes!.length : 0,
              countBuilder: (int? count, bool isLiked, String text) {
                var color = isLiked ? Colors.green : Colors.grey;
                Widget result;
                if (count == 0) {
                  result = Text(
                    "0",
                    style: TextStyle(color: color),
                  );
                } else {
                  result = Text(
                    text,
                    style: TextStyle(color: color),
                  );
                }
                return result;
              },
            ),
            if (!isReply)
              IconButton(
                onPressed: () {
                  Comment.pressedReply = !Comment.pressedReply;
                  Comment.docID = commentID!;
                  Get.forceAppUpdate();
                },
                icon: const Icon(Icons.reply),
              )
          ],
        ),
      ],
    ),
  );
}
