import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactSuggestion {
  const ContactSuggestion({
    required this.displayName,
    required this.phoneNumber,
  });

  final String displayName;
  final String phoneNumber;
}

class ContactsService {
  List<Contact>? _cache;

  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    final status = await FlutterContacts.permissions.check(PermissionType.read);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final status = await FlutterContacts.permissions.request(PermissionType.read);
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  Future<List<ContactSuggestion>> searchSuggestions(
    String query, {
    int limit = 6,
  }) async {
    if (!isSupported) return const [];
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    if (!await hasPermission()) return const [];

    final normalizedQuery = trimmed.toLowerCase();
    final normalizedDigits = _digitsOnly(trimmed);
    final contacts = await _allContacts();

    final matches = <ContactSuggestion>[];
    for (final c in contacts) {
      final name = (c.displayName ?? '').trim();
      if (name.isEmpty) continue;
      final phone = _firstPhone(c);
      if (phone == null) continue;
      final nameMatch = name.toLowerCase().contains(normalizedQuery);
      final phoneMatch = normalizedDigits.isNotEmpty &&
          _digitsOnly(phone).contains(normalizedDigits);
      if (!nameMatch && !phoneMatch) continue;

      matches.add(ContactSuggestion(displayName: name, phoneNumber: phone));
      if (matches.length >= limit) break;
    }
    return matches;
  }

  Future<List<Contact>> _allContacts() async {
    final existing = _cache;
    if (existing != null) return existing;
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
    _cache = contacts;
    return contacts;
  }

  String? _firstPhone(Contact c) {
    for (final phone in c.phones) {
      final value = phone.number.trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  String _digitsOnly(String input) =>
      input.replaceAll(RegExp(r'[^0-9+]'), '').trim();
}
