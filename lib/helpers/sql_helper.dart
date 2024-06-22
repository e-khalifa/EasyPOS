import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;

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
                     3- Iventory
                     4- Clients
                     5- Sales*/
  Future<bool> createTables() async {
    try {
      var batch = db!.batch();

      // Categories table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS categories(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT
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

      // Iventory table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS inventory (
          productId INTEGER PRIMARY KEY,
          quantity INTEGER NOT NULL,
          FOREIGN KEY(productId) REFERENCES products(id)
       )
      ''');
      print('Iventory table created.');

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

      // Sales table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id INTEGER PRIMARY KEY,
          saleDate TEXT NOT NULL,
          totalAmount DOUBLE NOT NULL,
          clientId INTEGER,
          FOREIGN KEY(clientId) REFERENCES clients(id)
        )
      ''');
      print('Sales table created.');

      var result = await batch.commit();
      print('Tables created: $result');
      return true;
    } catch (e) {
      print('Error creating tables: $e');
      return false;
    }
  }
}
