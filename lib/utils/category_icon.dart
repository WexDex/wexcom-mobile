import 'package:flutter/material.dart';

/// Compile-time Material icons for expense/gain categories.
/// Lookup avoids non-const `IconData(codePoint)` so release builds can tree-shake icons.
const _categoryIcons = <int, IconData>{
  0xe532: IconData(0xe532, fontFamily: 'MaterialIcons'), // Food
  0xe1b0: IconData(0xe1b0, fontFamily: 'MaterialIcons'), // Transport
  0xe3e7: IconData(0xe3e7, fontFamily: 'MaterialIcons'), // Bills
  0xe87e: IconData(0xe87e, fontFamily: 'MaterialIcons'), // Health
  0xf1cc: IconData(0xf1cc, fontFamily: 'MaterialIcons'), // Shopping
  0xe574: IconData(0xe574, fontFamily: 'MaterialIcons'), // Other
  0xe8f9: IconData(0xe8f9, fontFamily: 'MaterialIcons'), // Work
  0xe86f: IconData(0xe86f, fontFamily: 'MaterialIcons'), // Freelance
  0xe227: IconData(0xe227, fontFamily: 'MaterialIcons'), // Home
  0xe547: IconData(0xe547, fontFamily: 'MaterialIcons'), // Pets
  0xe02c: IconData(0xe02c, fontFamily: 'MaterialIcons'), // Entertainment
  0xe425: IconData(0xe425, fontFamily: 'MaterialIcons'), // Education
};

const _defaultCategoryIcon = IconData(0xe574, fontFamily: 'MaterialIcons');

IconData categoryIconData(int codePoint) =>
    _categoryIcons[codePoint] ?? _defaultCategoryIcon;
