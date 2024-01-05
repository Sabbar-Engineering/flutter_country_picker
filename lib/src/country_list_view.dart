import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/extensions.dart';
import 'package:country_picker/src/res/strings/ar.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'res/country_codes.dart';
import 'utils.dart';

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// An optional argument for showing "World Wide" option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument to disallow pop in case of usage in scaffold
  final bool shouldPop;

  final String? placeHolder;
  final String? selectedCountry;

  const CountryListView({
    Key? key,
    required this.onSelect,
    this.exclude,
    this.favorite,
    this.selectedCountry,
    this.countryFilter,
    this.showPhoneCode = false,
    this.shouldPop = true,
    this.countryListTheme,
    this.placeHolder,
    this.searchAutofocus = false,
    this.showWorldWide = false,
  })  : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        ),
        super(key: key);

  @override
  _CountryListViewState createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  final CountryService _countryService = CountryService();

  late List<Country> _countryList;
  late List<Country> _filteredList;
  List<Country>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;
  Country? selectedCountry;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    _countryList = _countryService.getAll();

    if (widget.selectedCountry != null) {
      selectedCountry = _countryList.firstWhere((element) =>
          element.countryCode.toLowerCase() ==
          widget.selectedCountry!.toLowerCase());
    }
    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    //Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.favorite != null) {
      _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => widget.exclude!.contains(element.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) => !widget.countryFilter!.contains(element.countryCode),
      );
    }

    _filteredList = <Country>[];
    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  @override
  Widget build(BuildContext context) {
    String? searchLabel;
    if (widget.placeHolder == null) {
      searchLabel = CountryLocalizations.of(context)
              ?.countryName(countryCode: 'search') ??
          'Search';
    } else {
      searchLabel = widget.placeHolder;
    }
    return Column(
      children: <Widget>[
        // const SizedBox(height: 12),
           TextField(
            enableSuggestions: false,
            autocorrect: false,
            autofocus: _searchAutofocus,
            controller: _searchController,
            decoration: InputDecoration(
              focusedBorder:
                  widget.countryListTheme?.inputDecoration?.focusedBorder,
              border: widget.countryListTheme?.inputDecoration?.border,
              errorBorder:
                  widget.countryListTheme?.inputDecoration?.errorBorder,
              enabledBorder:
                  widget.countryListTheme?.inputDecoration?.enabledBorder,
              fillColor: widget.countryListTheme?.inputDecoration?.fillColor,
              filled: widget.countryListTheme?.inputDecoration?.filled,
              contentPadding:
                  widget.countryListTheme?.inputDecoration?.contentPadding,
              hintText: widget.countryListTheme?.inputDecoration?.hintText,
              hintStyle: widget.countryListTheme?.inputDecoration?.hintStyle,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _filterSearchResults(_searchController.text);
                      },
                      child: _searchController.text.isEmpty
                          ? null
                          : widget
                              .countryListTheme?.inputDecoration?.suffixIcon,
                    ),
              prefixIcon: widget.countryListTheme?.inputDecoration?.prefixIcon,
            ),
            onChanged: _filterSearchResults,
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              if (_favoriteList != null) ...[
                ..._favoriteList!
                    .map<Widget>((currency) => _listRow(currency))
                    .toList(),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                //   child: Divider(thickness: 1),
                // ),
              ],
              ..._filteredList
                  .map<Widget>((country) => _listRow(country))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final Color _radioColor = (country == selectedCountry)
        ? Color.fromRGBO(250, 83, 46, 1)
        : Color.fromRGBO(136, 141, 160, 1);

    final Widget _radio = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(
          (country == selectedCountry)
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: _radioColor,
        ));
    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
          onTap: () {
            country.nameLocalized = CountryLocalizations.of(context)
                ?.countryName(countryCode: country.countryCode)
                ?.replaceAll(RegExp(r"\s+"), " ");
            widget.onSelect(country);
            if (widget.shouldPop) {
              Navigator.pop(context);
            } else {
              setState(() {
                selectedCountry = country;
              });
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: <Widget>[
                    Row(
                      children: [
                        _flagWidget(country),
                        const SizedBox(width:4),
                        if (widget.showPhoneCode && !country.iswWorldWide) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 45,
                            child: Text(
                              '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
                              style: _textStyle,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ] else
                          const SizedBox(width: 4),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        CountryLocalizations.of(context)
                                ?.countryName(countryCode: country.countryCode)
                                ?.replaceAll(RegExp(r"\s+"), " ") ??
                            country.name,
                        style: _textStyle,
                      ),
                    ),
                    _radio
                  ],
                ),
              ),
              const Divider(thickness: 1),
            ],
          )),
    );
  }

  Widget _flagWidget(Country country) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    if (country.iswWorldWide) {
      return Image.asset(
        'worldWide.png'.imagePath,
        package: 'country_picker',
        width: 27,
      );
    }

    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: Text(
        Utils.countryCodeToEmoji(country.countryCode),
        style: TextStyle(
          fontSize: widget.countryListTheme?.flagSize ?? 25,
        ),
      ),
    );
  }

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.trim().isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = extractTop<Country>(
        query: query,
        choices: [
          ..._countryList,
        ],
        limit: 10,
        cutoff: 60,
        getter: (e) =>
            "${e.name} ${e.countryCode} ${localizations?.countryName(countryCode: e.countryCode)?.toLowerCase()} ${ar[e.countryCode]}",
      ).map((e) => e.choice).toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
