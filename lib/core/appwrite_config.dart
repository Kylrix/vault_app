class AppwriteConfig {
  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://cloud.appwrite.io/v1',
  );

  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: 'kylrix',
  );

  static const String databaseId = String.fromEnvironment(
    'APPWRITE_VAULT_DATABASE_ID',
    defaultValue: 'VAULT',
  );

  static const String credentialsTableId = String.fromEnvironment(
    'APPWRITE_VAULT_CREDENTIALS_TABLE_ID',
    defaultValue: 'credentials',
  );
}
