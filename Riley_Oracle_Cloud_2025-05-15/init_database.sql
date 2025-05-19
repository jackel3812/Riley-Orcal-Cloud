# Database initialization script for Riley in Oracle VB

CREATE TABLE RILEY_CONVERSATIONS (
    id VARCHAR2(36) DEFAULT SYS_GUID() PRIMARY KEY,
    message_id VARCHAR2(36),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sender VARCHAR2(50),
    content CLOB,
    message_type VARCHAR2(20),
    attachment_url VARCHAR2(500)
);

CREATE TABLE RILEY_USER_PROFILES (
    user_id VARCHAR2(36) PRIMARY KEY,
    name VARCHAR2(100),
    preferences CLOB,
    last_interaction TIMESTAMP,
    voice_enabled NUMBER(1) DEFAULT 1
);

-- Create indexes for better performance
CREATE INDEX idx_conversations_timestamp ON RILEY_CONVERSATIONS(timestamp);
CREATE INDEX idx_conversations_sender ON RILEY_CONVERSATIONS(sender);
CREATE INDEX idx_user_profiles_last_interaction ON RILEY_USER_PROFILES(last_interaction);

-- Insert default user profile
INSERT INTO RILEY_USER_PROFILES (user_id, name, preferences, voice_enabled)
VALUES (
    SYS_GUID(),
    'Default User',
    '{"theme": "light", "notifications": true}',
    1
);
