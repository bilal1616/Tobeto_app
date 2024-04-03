import 'package:flutter/material.dart';

class PaginationWidget extends StatefulWidget {
  final int currentPage;
  final void Function(int) onPageChanged;

  PaginationWidget(
      {required this.currentPage,
      required this.onPageChanged,
      required int totalPages});

  @override
  _PaginationWidgetState createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  static const int totalPage = 2;
  static const int visiblePages = 2;

  Widget pageButton(int number) {
    bool isSelected = number == widget.currentPage;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: () {
          widget.onPageChanged(number);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.black : Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey,
          ),
          minimumSize: Size(32, 32),
        ),
        child: Text(
          '$number',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  List<Widget> buildPageButtons(int startPage, int endPage) {
    return List.generate(
      endPage - startPage + 1,
      (index) => pageButton(startPage + index),
    );
  }

  @override
  Widget build(BuildContext context) {
    int startPage = widget.currentPage - (visiblePages ~/ 2);
    startPage = startPage.clamp(1, totalPage - visiblePages + 1);

    int endPage = startPage + visiblePages - 1;
    if (endPage > totalPage) {
      endPage = totalPage;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: widget.currentPage > 1
              ? () {
                  widget.onPageChanged(widget.currentPage - 1);
                }
              : null,
        ),
        ...buildPageButtons(startPage, endPage),
        IconButton(
          icon: Icon(Icons.chevron_right, color: Colors.black),
          onPressed: widget.currentPage < totalPage
              ? () {
                  widget.onPageChanged(widget.currentPage + 1);
                }
              : null,
        ),
      ],
    );
  }
}
