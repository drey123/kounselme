// lib/data/remote/database_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:kounselme/config/env.dart';

class DatabaseService {
  static DatabaseService? _instance;
  PostgreSQLConnection? _connection;
  bool _isConnected = false;
  // UUID generator for creating unique identifiers

  // Maximum number of connection retries
  static const int _maxRetries = 3;

  // Singleton pattern
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  DatabaseService._internal();

  bool get isConnected => _isConnected;

  /// Initialize database connection
  Future<void> initialize() async {
    if (_isConnected) return;

    try {
      if (Env.neonDatabaseUrl.isNotEmpty) {
        // Use the connection URL if available
        final uri = Uri.parse(Env.neonDatabaseUrl);
        _connection = PostgreSQLConnection(
          uri.host,
          uri.port,
          uri.path.substring(1), // Remove leading slash
          username: uri.userInfo.split(':').first,
          password: uri.userInfo.split(':').last,
          useSSL: true,
        );
      } else {
        // Fall back to individual components
        _connection = PostgreSQLConnection(
          Env.neonHost,
          Env.neonPort,
          Env.neonDatabase,
          username: Env.neonUsername,
          password: Env.neonPassword,
          useSSL: true,
        );
      }

      await _connection?.open();
      _isConnected = true;

      if (kDebugMode) {
        print('Connected to Neon PostgreSQL database');
      }

      // Ensure tables exist
      await _createTablesIfNeeded();
    } catch (e) {
      _isConnected = false;
      if (kDebugMode) {
        print('Failed to connect to database: $e');
      }
      rethrow;
    }
  }

  /// Create necessary tables if they don't exist
  Future<void> _createTablesIfNeeded() async {
    // This creates the tables if they don't exist yet
    await _executeQuery('''
      CREATE TABLE IF NOT EXISTS profiles (
        id UUID PRIMARY KEY,
        email TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
        last_login TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        is_premium BOOLEAN DEFAULT FALSE
      );

      CREATE TABLE IF NOT EXISTS chat_messages_sync (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL,
        session_id TEXT NOT NULL,
        local_id TEXT NOT NULL,
        is_user BOOLEAN NOT NULL,
        message TEXT NOT NULL,
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(user_id, local_id)
      );

      CREATE TABLE IF NOT EXISTS journal_entries_sync (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL,
        local_id TEXT NOT NULL,
        title TEXT,
        content TEXT NOT NULL,
        tags TEXT[],
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(user_id, local_id)
      );

      CREATE TABLE IF NOT EXISTS mood_entries_sync (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL,
        local_id TEXT NOT NULL,
        mood_type TEXT NOT NULL,
        intensity INTEGER NOT NULL,
        note TEXT,
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(user_id, local_id)
      );

      CREATE INDEX IF NOT EXISTS idx_profile_email ON profiles(email);
      CREATE INDEX IF NOT EXISTS idx_chat_user_session ON chat_messages_sync(user_id, session_id);
      CREATE INDEX IF NOT EXISTS idx_journal_user_timestamp ON journal_entries_sync(user_id, timestamp);
      CREATE INDEX IF NOT EXISTS idx_mood_user_timestamp ON mood_entries_sync(user_id, timestamp);
    ''');
  }

  /// Ensure connection is active before executing queries
  Future<void> _reconnectIfNeeded() async {
    if (_connection == null || !_isConnected) {
      await initialize();
    }
  }

  /// Execute a query with retry logic
  Future<List<Map<String, dynamic>>> _executeQuery(
    String query, {
    Map<String, dynamic>? substitutionValues,
    int retryCount = 0,
  }) async {
    await _reconnectIfNeeded();

    try {
      final results = await _connection!.mappedResultsQuery(
        query,
        substitutionValues: substitutionValues,
      );

      // Convert the results to a simpler format
      final List<Map<String, dynamic>> mappedResults = [];
      for (final row in results) {
        final Map<String, dynamic> mappedRow = {};
        row.forEach((tableName, values) {
          mappedRow.addAll(values);
        });
        mappedResults.add(mappedRow);
      }

      return mappedResults;
    } catch (e) {
      if (kDebugMode) {
        print('Database query error: $e');
      }

      // If connection lost, try to reconnect
      if (e.toString().contains('connection closed') &&
          retryCount < _maxRetries) {
        _isConnected = false;
        await _reconnectIfNeeded();
        return _executeQuery(
          query,
          substitutionValues: substitutionValues,
          retryCount: retryCount + 1,
        );
      }

      rethrow;
    }
  }

  /// Execute a transaction with multiple queries
  /// This is a utility method for future use when we need to execute multiple queries in a transaction
  Future<void> executeTransaction(
      List<String> queries, List<Map<String, dynamic>> valuesList) async {
    await _reconnectIfNeeded();

    try {
      await _connection!.transaction((connection) async {
        for (int i = 0; i < queries.length; i++) {
          await connection.execute(
            queries[i],
            substitutionValues: i < valuesList.length ? valuesList[i] : null,
          );
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Database transaction error: $e');
      }
      rethrow;
    }
  }

  //================================
  // USER PROFILE OPERATIONS
  //================================

  /// Create a new user profile
  Future<void> createUserProfile(String userId, String email) async {
    try {
      await _executeQuery(
        'INSERT INTO profiles (id, email, created_at, last_login) '
        'VALUES (@id, @email, @created_at, @last_login) '
        'ON CONFLICT (id) DO NOTHING',
        substitutionValues: {
          'id': userId,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'last_login': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Create user profile error: $e');
      }
      rethrow;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await _executeQuery(
        'UPDATE profiles SET last_login = @last_login WHERE id = @id',
        substitutionValues: {
          'id': userId,
          'last_login': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Update last login error: $e');
      }
      rethrow;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final results = await _executeQuery(
        'SELECT * FROM profiles WHERE id = @id',
        substitutionValues: {'id': userId},
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Get user profile error: $e');
      }
      rethrow;
    }
  }

  /// Update premium status
  Future<void> updatePremiumStatus(String userId, bool isPremium) async {
    try {
      await _executeQuery(
        'UPDATE profiles SET is_premium = @is_premium WHERE id = @id',
        substitutionValues: {
          'id': userId,
          'is_premium': isPremium,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Update premium status error: $e');
      }
      rethrow;
    }
  }

  //================================
  // CHAT OPERATIONS
  //================================

  /// Sync chat messages to cloud
  Future<void> syncChatMessages(
    String userId,
    String sessionId,
    List<Map<String, dynamic>> messages,
  ) async {
    try {
      for (final message in messages) {
        await _executeQuery(
          'INSERT INTO chat_messages_sync (user_id, session_id, local_id, is_user, message, timestamp) '
          'VALUES (@user_id, @session_id, @local_id, @is_user, @message, @timestamp) '
          'ON CONFLICT (user_id, local_id) DO UPDATE SET '
          'message = EXCLUDED.message, '
          'timestamp = EXCLUDED.timestamp',
          substitutionValues: {
            'user_id': userId,
            'session_id': sessionId,
            'local_id': message['local_id'],
            'is_user': message['is_user'],
            'message': message['message'],
            'timestamp': message['timestamp'],
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync chat messages error: $e');
      }
      rethrow;
    }
  }

  /// Get chat messages by session
  Future<List<Map<String, dynamic>>> getChatMessages(
    String userId,
    String sessionId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _executeQuery(
        'SELECT * FROM chat_messages_sync '
        'WHERE user_id = @user_id AND session_id = @session_id '
        'ORDER BY timestamp DESC '
        'LIMIT @limit OFFSET @offset',
        substitutionValues: {
          'user_id': userId,
          'session_id': sessionId,
          'limit': limit,
          'offset': offset,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Get chat messages error: $e');
      }
      rethrow;
    }
  }

  /// Get chat sessions for a user
  Future<List<Map<String, dynamic>>> getChatSessions(String userId) async {
    try {
      return await _executeQuery(
        'SELECT DISTINCT session_id, MAX(timestamp) as last_message_time '
        'FROM chat_messages_sync '
        'WHERE user_id = @user_id '
        'GROUP BY session_id '
        'ORDER BY last_message_time DESC',
        substitutionValues: {'user_id': userId},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Get chat sessions error: $e');
      }
      rethrow;
    }
  }

  //================================
  // JOURNAL OPERATIONS
  //================================

  /// Sync journal entries to cloud
  Future<void> syncJournalEntries(
    String userId,
    List<Map<String, dynamic>> entries,
  ) async {
    try {
      for (final entry in entries) {
        await _executeQuery(
          'INSERT INTO journal_entries_sync (user_id, local_id, title, content, tags, timestamp) '
          'VALUES (@user_id, @local_id, @title, @content, @tags, @timestamp) '
          'ON CONFLICT (user_id, local_id) DO UPDATE SET '
          'title = EXCLUDED.title, '
          'content = EXCLUDED.content, '
          'tags = EXCLUDED.tags, '
          'timestamp = EXCLUDED.timestamp',
          substitutionValues: {
            'user_id': userId,
            'local_id': entry['local_id'],
            'title': entry['title'],
            'content': entry['content'],
            'tags': entry['tags'],
            'timestamp': entry['timestamp'],
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync journal entries error: $e');
      }
      rethrow;
    }
  }

  /// Get journal entries for a user
  Future<List<Map<String, dynamic>>> getJournalEntries(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _executeQuery(
        'SELECT * FROM journal_entries_sync '
        'WHERE user_id = @user_id '
        'ORDER BY timestamp DESC '
        'LIMIT @limit OFFSET @offset',
        substitutionValues: {
          'user_id': userId,
          'limit': limit,
          'offset': offset,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Get journal entries error: $e');
      }
      rethrow;
    }
  }

  //================================
  // MOOD TRACKING OPERATIONS
  //================================

  /// Sync mood entries to cloud
  Future<void> syncMoodEntries(
    String userId,
    List<Map<String, dynamic>> entries,
  ) async {
    try {
      for (final entry in entries) {
        await _executeQuery(
          'INSERT INTO mood_entries_sync (user_id, local_id, mood_type, intensity, note, timestamp) '
          'VALUES (@user_id, @local_id, @mood_type, @intensity, @note, @timestamp) '
          'ON CONFLICT (user_id, local_id) DO UPDATE SET '
          'mood_type = EXCLUDED.mood_type, '
          'intensity = EXCLUDED.intensity, '
          'note = EXCLUDED.note, '
          'timestamp = EXCLUDED.timestamp',
          substitutionValues: {
            'user_id': userId,
            'local_id': entry['local_id'],
            'mood_type': entry['mood_type'],
            'intensity': entry['intensity'],
            'note': entry['note'],
            'timestamp': entry['timestamp'],
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync mood entries error: $e');
      }
      rethrow;
    }
  }

  /// Get mood entries for a user
  Future<List<Map<String, dynamic>>> getMoodEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 30,
  }) async {
    try {
      String query = 'SELECT * FROM mood_entries_sync WHERE user_id = @user_id';
      final Map<String, dynamic> values = {'user_id': userId};

      if (startDate != null) {
        query += ' AND timestamp >= @start_date';
        values['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        query += ' AND timestamp <= @end_date';
        values['end_date'] = endDate.toIso8601String();
      }

      query += ' ORDER BY timestamp DESC LIMIT @limit';
      values['limit'] = limit;

      return await _executeQuery(query, substitutionValues: values);
    } catch (e) {
      if (kDebugMode) {
        print('Get mood entries error: $e');
      }
      rethrow;
    }
  }

  /// Get mood trends for a time period
  Future<Map<String, dynamic>> getMoodTrends(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final results = await _executeQuery(
        '''
        SELECT
          mood_type,
          AVG(intensity) as avg_intensity,
          COUNT(*) as count
        FROM mood_entries_sync
        WHERE user_id = @user_id
          AND timestamp BETWEEN @start_date AND @end_date
        GROUP BY mood_type
        ORDER BY avg_intensity DESC
        ''',
        substitutionValues: {
          'user_id': userId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      // Process the results into a trends map
      final Map<String, dynamic> trends = {
        'period_start': startDate.toIso8601String(),
        'period_end': endDate.toIso8601String(),
        'mood_types': <String, Map<String, dynamic>>{},
      };

      for (final result in results) {
        trends['mood_types'][result['mood_type']] = {
          'average_intensity': result['avg_intensity'],
          'count': result['count'],
        };
      }

      return trends;
    } catch (e) {
      if (kDebugMode) {
        print('Get mood trends error: $e');
      }
      rethrow;
    }
  }

  /// Close the database connection
  Future<void> close() async {
    await _connection?.close();
    _isConnected = false;
  }
}
