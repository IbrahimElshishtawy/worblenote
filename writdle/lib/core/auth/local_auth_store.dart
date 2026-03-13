import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/domain/entities/local_auth_account.dart';

class LocalAuthStore {
  static const _accountsKey = 'local_auth_accounts';
  static const _currentAccountIdKey = 'local_auth_current_account_id';

  static const String developerEmail = 'shishtawy@gmail.com';
  static const String developerPassword = 'hima123';

  static LocalAuthAccount get _developerAccount => LocalAuthAccount(
        id: 'local_dev_account',
        name: 'Developer Account',
        email: developerEmail,
        password: developerPassword,
        bio: 'Local account stored on this phone for fast testing.',
        createdAt: DateTime(2026, 3, 14),
      );

  static Future<List<LocalAuthAccount>> getAccounts() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_accountsKey);
    final accounts = raw == null || raw.isEmpty
        ? <LocalAuthAccount>[]
        : (jsonDecode(raw) as List<dynamic>)
            .map((item) =>
                LocalAuthAccount.fromJson(item as Map<String, dynamic>))
            .toList();

    if (!accounts.any((item) => item.email == developerEmail)) {
      accounts.insert(0, _developerAccount);
      await saveAccounts(accounts);
    }

    return accounts;
  }

  static Future<void> saveAccounts(List<LocalAuthAccount> accounts) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _accountsKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
  }

  static Future<LocalAuthAccount?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.email.trim().toLowerCase() == normalized) {
        return account;
      }
    }
    return null;
  }

  static Future<LocalAuthAccount?> getCurrentAccount() async {
    final preferences = await SharedPreferences.getInstance();
    final currentId = preferences.getString(_currentAccountIdKey);
    if (currentId == null || currentId.isEmpty) {
      return null;
    }

    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.id == currentId) {
        return account;
      }
    }
    return null;
  }

  static Future<String?> getCurrentUserId() async {
    final account = await getCurrentAccount();
    return account?.id;
  }

  static Future<void> setCurrentAccount(LocalAuthAccount account) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currentAccountIdKey, account.id);
    await preferences.setBool('isLoggedIn', true);
  }

  static Future<void> clearCurrentAccount() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentAccountIdKey);
    await preferences.setBool('isLoggedIn', false);
  }

  static Future<bool> isAuthenticated() async {
    return await getCurrentAccount() != null;
  }

  static Future<LocalAuthAccount> registerAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await findByEmail(normalizedEmail);
    if (existing != null) {
      throw Exception('This email is already registered on this device.');
    }

    final accounts = await getAccounts();
    final account = LocalAuthAccount(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      createdAt: DateTime.now(),
    );
    accounts.add(account);
    await saveAccounts(accounts);
    await setCurrentAccount(account);
    return account;
  }

  static Future<void> updateAccount(LocalAuthAccount updatedAccount) async {
    final accounts = await getAccounts();
    final updatedAccounts = accounts
        .map((account) =>
            account.id == updatedAccount.id ? updatedAccount : account)
        .toList();
    await saveAccounts(updatedAccounts);
    await setCurrentAccount(updatedAccount);
  }
}
