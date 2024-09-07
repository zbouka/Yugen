import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:yugen/screens/auth/auth.dart';
import 'package:collection/collection.dart';
import '../../assets/loading.dart';

/// Shows some characteristis about the item like title, img, release date, language or status
class InfoWidget extends StatefulWidget {
  final String img, title, year, status, lang, collectionName;
  final int numberChapters;

  const InfoWidget({
    super.key,
    required this.img,
    required this.title,
    required this.year,
    required this.status,
    required this.lang,
    required this.numberChapters,
    required this.collectionName,
  });

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  late CollectionReference<Map<String, dynamic>> collection;
  late Future<double> avgRating;
  late Future<DocumentSnapshot<Map<String, dynamic>>> ratings;
  @override
  void initState() {
    super.initState();
    collection = FirebaseFirestore.instance.collection(widget.collectionName);
    avgRating = getAverageRating();
    ratings = getRatings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRatings() {
    return collection
        .doc("${widget.title}(${widget.lang.toLowerCase()})")
        .collection("Ratings")
        .doc(Auth().getUser()!.uid)
        .get();
  }

  Future<double> getAverageRating() async {
    var docRef = await collection
        .doc("${widget.title}(${widget.lang.toLowerCase()})")
        .collection('Ratings')
        .get();

    if (docRef.docs.isNotEmpty) {
      var average = docRef.docs.map((e) => e['rating']).toList();
      await collection
          .doc("${widget.title}(${widget.lang.toLowerCase()})")
          .update({"averageRating": List<double>.from(average).average});

      return (List<double>.from(average).average);
    } else {
      return 0;
    }
  }

  Future<void> deleteRating() async {
    try {
      await collection
          .doc("${widget.title}(${widget.lang.toLowerCase()})")
          .collection('Ratings')
          .doc(Auth().getUser()!.uid)
          .delete();
    } catch (e) {}
  }

  void saveRating(double rating) async {
    try {
      var docRef = collection
          .doc("${widget.title}(${widget.lang.toLowerCase()})")
          .collection('Ratings')
          .doc(Auth().getUser()!.uid);
      docRef.get().then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          docRef.update({
            "rating": rating,
          });
        } else {
          docRef.set({
            "rating": rating,
          }, SetOptions(merge: true));
          collection
              .doc("${widget.title}(${widget.lang.toLowerCase()})")
              .set({"averageRating": rating}, SetOptions(merge: true));
        }
      });
    } catch (e) {}
  }

  bool isLandScape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 300
                      : 200,
                  width: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 200
                      : 130,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.img,
                      errorBuilder: (context, error, stackTrace) {
                        //setState() not needed, because the widget doesn´t even build

                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        );
                      },
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Loading();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<double>(
                future: avgRating,
                builder:
                    (BuildContext context, AsyncSnapshot<double> snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      "0.0",
                      style: TextStyle(fontSize: isLandScape() ? 25 : 19),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loading();
                  } else {
                    return CircularPercentIndicator(
                      radius: isLandScape() ? 75 : 50.0,
                      lineWidth: 13.0,
                      animation: true,
                      percent: snapshot.data! / 5,
                      center: Text(
                        snapshot.data!.toStringAsFixed(2),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isLandScape() ? 35 : 19),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.purple,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 400
                        : 200,
                child: Text(
                  "${widget.title}\n",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: isLandScape() ? 30 : 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "status".tr,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              Text(
                widget.status,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${'language'.tr}:",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              Text(
                widget.lang == "es" ? "spanish".tr : "english".tr,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "year".tr,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              Text(
                widget.year,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "numberC".tr,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              Text(
                widget.numberChapters.toString(),
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "rating".tr,
                style: TextStyle(fontSize: isLandScape() ? 30 : 18),
              ),
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: ratings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loading();
                  } else {
                    return RatingBar.builder(
                      initialRating:
                          snapshot.data != null && snapshot.data!.data() != null
                              ? snapshot.data!.get('rating')
                              : 0,
                      minRating: 0,
                      itemSize: isLandScape() ? 50 : 35,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) async {
                        if (rating == 0) {
                          await deleteRating();
                        }
                        saveRating(rating);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
