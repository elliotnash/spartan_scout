import 'package:flutter/cupertino.dart';

// HTTP Constants
//const kBaseUrl = "https://scout.elliotnash.org";
const kBaseUrl = "http://localhost:8080";

const kRetryInterval = Duration(seconds: 15);

// Copied from flutter sdk
const kDefaultNavBarBackgroundAlpha = 200;
const kNavBarShowLargeTitleThreshold = 10.0;
const kDefaultNavBarBorderColor = Color(0x4D000000);

const BorderSide kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  width: 0.0,
);
const Border kDefaultRoundedBorder = Border(
  top: kDefaultRoundedBorderSide,
  bottom: kDefaultRoundedBorderSide,
  left: kDefaultRoundedBorderSide,
  right: kDefaultRoundedBorderSide,
);

// App consts
const kSettingsEntryPadding = 10.0;
const kSettingsEntryHeight = 40.0;
