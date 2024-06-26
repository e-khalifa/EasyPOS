import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;

  Future<void> registerForeignKeys() async {
    await db!.rawQuery('PRAGMA foreign_keys = on');
    var result = await db!.rawQuery('PRAGMA foreign_keys');
    print('foreign keys result : $result');
  }

  // Creating database
  Future<void> initDb() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('easypos.db');
        print('Web Database creation done!');
        await createTables();
      } else {
        db = await openDatabase(
          'easypos.db',
          version: 1,
          onCreate: (db, version) async {
            print('Database creation done!');
            await createTables();
          },
        );
      }
    } catch (e) {
      print('Error creating database: $e');
    }
  }

  /* Creating tables:
                     1- Categories
                     2- Products
                     3- Clients
                     4- Orders
                     5- Order Product Items
                     */

  Future<bool> createTables() async {
    try {
      await registerForeignKeys();
      var batch = db!.batch();

      // Categories table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS categories(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          status TEXT
        )
      ''');
      print('Categories table created.');

      // Products table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS products(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          price DOUBLE NOT NULL,
          isAvailable BOOLEAN,
          stock INTEGER NOT NULL,
          image TEXT NOT NULL,
          categoryId INTEGER,
          FOREIGN KEY(categoryId) REFERENCES categories(id)
          ON Delete restrict
        )
      ''');
      print('Products table created.');

      // Clients table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS clients(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          address TEXT,
          email TEXT
        )
      ''');
      print('Clients table created.');

      // Orders table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id INTEGER PRIMARY KEY,
          label TEXT NOT NULL,
          orginalPrice DOUBLE NOT NULL,
          discount DOUBLE,
          discountedPrice DOUBLE,
          comment TEXT,
          clientId INTEGER,
          FOREIGN KEY(clientId) REFERENCES clients(id)
          ON Delete restrict
        )
      ''');
      print('Orders table created.');

      // OrderProductItems table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS orderItems (
          id INTEGER PRIMARY KEY,
          productCount INTEGER,
          productId INTEGER,
          orderId INTEGER,
          FOREIGN KEY(orderId) REFERENCES orders(id)
          ON Delete restrict
        )
      ''');
      print('OrderProductItems table created.');

      var result = await batch.commit();
      print('Tables created: $result');
      return true;
    } catch (e) {
      print('Error creating tables: $e');
      return false;
    }
  }
}
