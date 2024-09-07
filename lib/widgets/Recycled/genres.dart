import 'package:flutter/material.dart';

/// Classes to show the anime/manga genres
class GenresWidget extends StatefulWidget {
  final List<dynamic> genres;
  const GenresWidget({
    super.key,
    required this.genres,
  });

  @override
  State<GenresWidget> createState() => _GenresWidgetState();
}

class _GenresWidgetState extends State<GenresWidget> {
  bool isLandScape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          Wrap(
            spacing: 10.0,
            runSpacing: 4.0,
            children: List<Widget>.generate(
              widget.genres.length,
              (index) {
                return Chip(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  )),
                  label: Text(
                    widget.genres[index]
                            .toString()
                            .trimLeft()[0]
                            .toUpperCase() +
                        widget.genres[index].toString().trimLeft().substring(1),
                    style: TextStyle(fontSize: isLandScape() ? 22 : 15),
                  ),
                );
              },
            ).toList(),
          )
        ],
      ),
    );
  }
}
