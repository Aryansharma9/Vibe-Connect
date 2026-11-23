-- V3: Sample students and moments across LIET and Greater Noida Hub

-- Create sample student profiles for LIET, Bennett, Galgotias, Sharda
INSERT INTO users (id, phone_number, full_name, gender, dob, college_id, dating_intent, bio, is_student_verified, is_photo_verified, avatar_url, status)
VALUES
('a1111111-1111-1111-1111-111111111111', '9811111111', 'Ananya Verma', 'FEMALE', '2004-03-12', 
 (SELECT id FROM colleges WHERE short_code = 'LIET'), 'LONG_TERM', 'CSE 3rd Year • Tech, chai & indie playlists ☕🎧', true, true, null, 'ACTIVE'),

('a2222222-2222-2222-2222-222222222222', '9822222222', 'Rohan Mehta', 'MALE', '2003-11-25', 
 (SELECT id FROM colleges WHERE short_code = 'LIET'), 'STUDY_BUDDY', 'Knowledge Park survivor. Building Flutter apps & competitive coding 💻', true, true, null, 'ACTIVE'),

('a3333333-3333-3333-3333-333333333333', '9833333333', 'Priya Singh', 'FEMALE', '2004-07-19', 
 (SELECT id FROM colleges WHERE short_code = 'BENNETT'), 'GO_WITH_THE_FLOW', 'Bennett Law • Weekend cafe crawler in Noida Sector 104 ✨', true, true, null, 'ACTIVE'),

('a4444444-4444-4444-4444-444444444444', '9844444444', 'Kabir Malhotra', 'MALE', '2003-09-08', 
 (SELECT id FROM colleges WHERE short_code = 'GALGOTIAS'), 'CASUAL', 'Gym & Valorant • Looking for badminton partner on weekends 🏸', true, true, null, 'ACTIVE'),

('a5555555-5555-5555-5555-555555555555', '9855555555', 'Sneha Kapoor', 'FEMALE', '2004-01-30', 
 (SELECT id FROM colleges WHERE short_code = 'SHARDA'), 'LONG_TERM', 'Medical student • Reader, night owl & photography hobbyist 📷', true, true, null, 'ACTIVE')
ON CONFLICT (phone_number) DO NOTHING;

-- Seed peer answers to today's question
INSERT INTO prompt_answers (question_id, user_id, answer_text)
SELECT 
    q.id,
    u.id,
    CASE 
        WHEN u.phone_number = '9811111111' THEN 'The rooftop library staircase at LIET during sunset. Best breeze and nobody bothers you.'
        WHEN u.phone_number = '9822222222' THEN 'The canteen Nescafe stall right before the 10 AM lab. Overpriced coffee but elite campus gossip.'
        WHEN u.phone_number = '9833333333' THEN 'The central lawn near Bennett football ground when it rains. Pure aesthetic vibes.'
        WHEN u.phone_number = '9844444444' THEN 'The indoor badminton court between classes. Easiest way to skip boring lectures.'
        WHEN u.phone_number = '9855555555' THEN 'The little book corner in the Sharda block 4 cafe with earphones on.'
    END
FROM daily_questions q
CROSS JOIN users u
WHERE q.active_date = CURRENT_DATE
  AND u.phone_number IN ('9811111111', '9822222222', '9833333333', '9844444444', '9855555555')
ON CONFLICT (question_id, user_id) DO NOTHING;
