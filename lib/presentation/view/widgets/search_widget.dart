import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key, required this.onSearch});
  final Function onSearch;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController searchController = TextEditingController();

  Timer? _debounce;
  final int _debouncetime = 1000;
  @override
  void didChangeDependencies() {
    widget.onSearch(searchController.text);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 40.h,
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search for a story',
            contentPadding: const EdgeInsets.all(10),
            border: InputBorder.none,
            suffixIcon:
                (searchController.text.isEmpty)
                    ? Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                    : IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        searchController.clear();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
          ),
          onChanged: (value) {
            if (_debounce?.isActive ?? false) {
              _debounce?.cancel();
            }
            _debounce = Timer(Duration(milliseconds: _debouncetime), () {});
          },
        ),
      ),
    );
  }
}
