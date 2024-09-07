import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ComentBox to send the message into Firebase
class CommentBox extends StatefulWidget {
  final Widget image;
  final TextEditingController controller;
  final FocusNode myFocusNode;
  final Function(String comment) onSend;
  final Function() onCancel;
  const CommentBox({
    super.key,
    required this.image,
    required this.onSend,
    required this.onCancel,
    required this.controller,
    required this.myFocusNode,
  });

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final ScrollController _scrollController = ScrollController();

  String comment = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 10, color: Colors.transparent),
              widget.image,
              Container(width: 7, color: Colors.transparent),
              Expanded(
                child: TextField(
                  scrollController: _scrollController,
                  focusNode: widget.myFocusNode,
                  decoration: InputDecoration(
                    hintText: "commentHere".tr,
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  scrollPhysics: const BouncingScrollPhysics(),
                  maxLines: null,
                  controller: widget.controller,
                  textAlign: TextAlign.left,
                  onChanged: (value) {
                    setState(() {
                      comment = value;
                    });
                  },
                  onSubmitted: (value) {
                    widget.myFocusNode.unfocus();

                    widget.onCancel();
                  },
                  onEditingComplete: () {
                    widget.myFocusNode.unfocus();

                    widget.onCancel();
                  },
                ),
              ),
              Container(width: 7, color: Colors.transparent),
            ],
          ),
          Visibility(
              visible: comment != "" ? true : false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                      label: Text('cancel'.tr),
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        widget.onCancel();
                        widget.controller.clear();
                        widget.myFocusNode.unfocus();
                        comment = "";
                      }),
                  TextButton.icon(
                      label: Text('send'.tr),
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        widget.onSend(comment);
                        widget.controller.clear();
                        widget.myFocusNode.unfocus();
                        comment = "";
                      })
                ],
              )),
        ],
      ),
    );
  }
}
