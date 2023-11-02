import 'package:flutter/material.dart';

import 'country.dart';
import 'country_list_theme_data.dart';
import 'country_list_view.dart';

void showCountryListBottomSheet({
  required BuildContext context,
  required ValueChanged<Country> onSelect,
  VoidCallback? onClosed,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode = false,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus = false,
  bool showWorldWide = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _builder(
          context,
          onSelect,
          favorite,
          exclude,
          countryFilter,
          showPhoneCode,
          countryListTheme,
          searchAutofocus,
          showWorldWide,
        ),
  ).whenComplete(() {
    if (onClosed != null) onClosed();
  });
}

Widget countryList({
  required ValueChanged<Country> onSelect,
  VoidCallback? onClosed,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode = false,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus = false,
  bool showWorldWide = false,
  String? placeHolder,
}) {
  return _builderListView(
    onSelect,
    favorite,
    exclude,
    countryFilter,
    showPhoneCode,
    countryListTheme,
    searchAutofocus,
    showWorldWide,
    placeHolder,
  );
}

Widget _builder(BuildContext context,
    ValueChanged<Country> onSelect,
    List<String>? favorite,
    List<String>? exclude,
    List<String>? countryFilter,
    bool showPhoneCode,
    CountryListThemeData? countryListTheme,
    bool searchAutofocus,
    bool showWorldWide,) {
  final device = MediaQuery
      .of(context)
      .size
      .height;
  final statusBarHeight = MediaQuery
      .of(context)
      .padding
      .top;
  final height = countryListTheme?.bottomSheetHeight ??
      device - (statusBarHeight + (kToolbarHeight / 1.5));

  Color? _backgroundColor = countryListTheme?.backgroundColor ??
      Theme
          .of(context)
          .bottomSheetTheme
          .backgroundColor;
  if (_backgroundColor == null) {
    if (Theme
        .of(context)
        .brightness == Brightness.light) {
      _backgroundColor = Colors.white;
    } else {
      _backgroundColor = Colors.black;
    }
  }

  final BorderRadius _borderRadius = countryListTheme?.borderRadius ??
      const BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      );

  return Container(
    height: height,
    decoration: BoxDecoration(
      color: _backgroundColor,
      borderRadius: _borderRadius,
    ),
    child: countryListView(
      onSelect: onSelect,
      exclude: exclude,
      favorite: favorite,
      countryFilter: countryFilter,
      showPhoneCode: showPhoneCode,
      countryListTheme: countryListTheme,
      searchAutofocus: searchAutofocus,
      showWorldWide: showWorldWide,
      shouldPop: true,
    ),
  );
}











Widget _builderListView(
    ValueChanged<Country> onSelect,
    List<String>? favorite,
    List<String>? exclude,
    List<String>? countryFilter,
    bool showPhoneCode,
    CountryListThemeData? countryListTheme,
    bool searchAutofocus,
    bool showWorldWide,
    String? placeHolder,
    ) {
  return countryListView(
    onSelect: onSelect,
    exclude: exclude,
    favorite: favorite,
    countryFilter: countryFilter,
    showPhoneCode: showPhoneCode,
    countryListTheme: countryListTheme,
    searchAutofocus: searchAutofocus,
    showWorldWide: showWorldWide,
    shouldPop: false,
    placeHolder:placeHolder,
  );

}


Widget countryListView({
  required ValueChanged<Country> onSelect,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode = false,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus = false,
  bool showWorldWide = false,
  bool shouldPop = true,
  String? placeHolder,
}) {
  return CountryListView(
    onSelect: onSelect,
    shouldPop: shouldPop,
    exclude: exclude,
    favorite: favorite,
    countryFilter: countryFilter,
    showPhoneCode: showPhoneCode,
    countryListTheme: countryListTheme,
    searchAutofocus: searchAutofocus,
    showWorldWide: showWorldWide,
    placeHolder: placeHolder,
  );
}

