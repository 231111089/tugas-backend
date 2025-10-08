// database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cashease.db');
    print('📍 Database path: $path');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    print('🔨 Creating database table...');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT UNIQUE NOT NULL,
        pin TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    print('✅ Table users created successfully');
  }

  // Hash PIN untuk keamanan
  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrasi user baru
  Future<bool> registerUser(String phone, String pin) async {
    try {
      print('📝 Attempting to register user...');
      print('   Phone: $phone');
      print('   PIN length: ${pin.length}');

      final db = await database;

      // Cek apakah nomor sudah terdaftar
      final existingUser = await getUserByPhone(phone);
      if (existingUser != null) {
        print('❌ User already exists!');
        return false; // User sudah ada
      }

      print('✅ Phone number available, creating user...');

      final hashedPin = _hashPin(pin);
      print('   Hashed PIN: ${hashedPin.substring(0, 10)}...');

      final result = await db.insert('users', {
        'phone': phone,
        'pin': hashedPin,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      print('✅ User registered successfully with ID: $result');

      // Verifikasi data tersimpan
      final savedUser = await getUserByPhone(phone);
      print('🔍 Verification - User saved: ${savedUser != null}');

      return true;
    } catch (e) {
      print('❌ Error registering user: $e');
      print('   Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Cek user berdasarkan nomor telepon
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );

      if (results.isNotEmpty) {
        print('👤 User found: $phone');
        return results.first;
      }
      print('👻 User not found: $phone');
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // Validasi login
  Future<bool> validateLogin(String phone, String pin) async {
    try {
      print('🔐 Validating login...');
      print('   Phone: $phone');

      final user = await getUserByPhone(phone);
      if (user == null) {
        print('❌ User not found');
        return false;
      }

      final hashedPin = _hashPin(pin);
      final isValid = user['pin'] == hashedPin;

      print(isValid ? '✅ Login successful' : '❌ Wrong PIN');
      return isValid;
    } catch (e) {
      print('❌ Error validating login: $e');
      return false;
    }
  }

  // Verifikasi PIN (untuk password screen)
  Future<bool> verifyPin(String phone, String pin) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'phone = ? AND pin = ?',
        whereArgs: [phone, _hashPin(pin)],
      );
      return results.isNotEmpty;
    } catch (e) {
      print('❌ Error verifying PIN: $e');
      return false;
    }
  }

  // Update PIN
  Future<bool> updatePin(String phone, String newPin) async {
    try {
      print('🔄 Updating PIN for: $phone');

      final db = await database;
      final user = await getUserByPhone(phone);

      if (user == null) {
        print('❌ User not found');
        return false;
      }

      await db.update(
        'users',
        {'pin': _hashPin(newPin)},
        where: 'phone = ?',
        whereArgs: [phone],
      );

      print('✅ PIN updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating PIN: $e');
      return false;
    }
  }

  // Cek apakah user sudah terdaftar
  Future<bool> isUserRegistered(String phone) async {
    final user = await getUserByPhone(phone);
    return user != null;
  }

  // Get all users (untuk debugging)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await database;
      final users = await db.query('users');
      print('📊 Total users in database: ${users.length}');
      return users;
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  // Delete user (untuk testing/debugging)
  Future<bool> deleteUser(String phone) async {
    try {
      print('🗑️ Deleting user: $phone');

      final db = await database;
      final result = await db.delete(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );

      print(result > 0 ? '✅ User deleted' : '❌ User not found');
      return result > 0;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  // Clear all data (untuk testing)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('users');
      print('🧹 All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
