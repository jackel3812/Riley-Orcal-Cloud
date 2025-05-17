-- MySQL initialization script for Riley

CREATE DATABASE IF NOT EXISTS riley_db;
USE riley_db;

CREATE TABLE IF NOT EXISTS riley_conversations (
    id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    message_id VARCHAR(36),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sender VARCHAR(50),
    content TEXT,
    message_type VARCHAR(20),
    attachment_url VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS riley_user_profiles (
    user_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100),
    preferences JSON,
    last_interaction TIMESTAMP,
    voice_enabled BOOLEAN DEFAULT TRUE
);

-- Create indexes for better performance
CREATE INDEX idx_conversations_timestamp ON riley_conversations(timestamp);
CREATE INDEX idx_conversations_sender ON riley_conversations(sender);
CREATE INDEX idx_user_profiles_last_interaction ON riley_user_profiles(last_interaction);

-- Insert default user profile
INSERT INTO riley_user_profiles (user_id, name, preferences, voice_enabled)
VALUES (
    UUID(),
    'Default User',
    '{"theme": "light", "notifications": true}',
    1
);
