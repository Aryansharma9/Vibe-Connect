-- V1: Initial Schema & Greater Noida College Seed Data

-- 1. Colleges
CREATE TABLE colleges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    short_code VARCHAR(50) UNIQUE NOT NULL,
    email_domain VARCHAR(100),
    city VARCHAR(100) DEFAULT 'Greater Noida',
    locality VARCHAR(100) DEFAULT 'Knowledge Park',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pre-seed LIET and Greater Noida Hub
INSERT INTO colleges (name, short_code, email_domain, city, locality) VALUES
('Lloyd Institute of Engineering and Technology', 'LIET', 'lloydcollege.in', 'Greater Noida', 'Knowledge Park II'),
('Bennett University', 'BENNETT', 'bennett.edu.in', 'Greater Noida', 'Tech Zone II'),
('Galgotias University', 'GALGOTIAS', 'galgotiasuniversity.edu.in', 'Greater Noida', 'Yamuna Expressway'),
('Sharda University', 'SHARDA', 'sharda.ac.in', 'Greater Noida', 'Knowledge Park III'),
('GL Bajaj Institute of Technology & Management', 'GLBAJAJ', 'glbitm.ac.in', 'Greater Noida', 'Knowledge Park II'),
('Gautam Buddha University', 'GBU', 'gbu.ac.in', 'Greater Noida', 'Yamuna Expressway'),
('Amity University', 'AMITY_NOIDA', 'amity.edu', 'Noida', 'Sector 125'),
('Jaypee Institute of Information Technology', 'JIIT', 'jiit.ac.in', 'Noida', 'Sector 62');

-- 2. Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    dob DATE NOT NULL,
    college_id UUID REFERENCES colleges(id),
    dating_intent VARCHAR(50) NOT NULL DEFAULT 'GO_WITH_THE_FLOW',
    bio VARCHAR(500),
    is_student_verified BOOLEAN DEFAULT FALSE,
    is_photo_verified BOOLEAN DEFAULT FALSE,
    avatar_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Daily Prompts
CREATE TABLE daily_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_text TEXT NOT NULL,
    active_date DATE UNIQUE NOT NULL,
    category VARCHAR(50) DEFAULT 'VIBE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed initial daily prompt
INSERT INTO daily_questions (prompt_text, active_date, category) VALUES
('What is one campus spot where everyone goes, but you actually enjoy it?', CURRENT_DATE, 'CAMPUS_LIFE');

-- 4. Prompt Answers (The Moments)
CREATE TABLE prompt_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID REFERENCES daily_questions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    answer_text TEXT NOT NULL,
    media_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_user_daily_answer UNIQUE(question_id, user_id)
);

-- 5. Connection Requests
CREATE TABLE connection_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    context_type VARCHAR(30) NOT NULL,
    context_id UUID,
    initial_note VARCHAR(140),
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_connection_pair UNIQUE(sender_id, receiver_id)
);

-- 6. Conversations & Messages
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    connection_request_id UUID REFERENCES connection_requests(id),
    user_one_id UUID REFERENCES users(id),
    user_two_id UUID REFERENCES users(id),
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id),
    content TEXT NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
