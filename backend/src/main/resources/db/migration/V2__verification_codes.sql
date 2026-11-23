-- V2: Verification Codes and User College Email Support

ALTER TABLE users ADD COLUMN IF NOT EXISTS college_email VARCHAR(100);

CREATE TABLE IF NOT EXISTS verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient VARCHAR(100) NOT NULL, -- Phone number or College Email
    code VARCHAR(10) NOT NULL,
    type VARCHAR(20) NOT NULL,       -- 'PHONE_LOGIN', 'COLLEGE_EMAIL'
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verification_recipient_type ON verification_codes(recipient, type);
