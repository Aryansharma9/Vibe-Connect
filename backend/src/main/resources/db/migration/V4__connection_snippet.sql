-- V4: Add context_snippet to connection_requests

ALTER TABLE connection_requests ADD COLUMN IF NOT EXISTS context_snippet VARCHAR(500);
