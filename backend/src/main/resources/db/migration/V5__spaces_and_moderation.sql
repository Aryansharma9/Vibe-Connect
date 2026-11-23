-- V5: Themed Interest Spaces & Safety Moderation

CREATE TABLE IF NOT EXISTS spaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(20) NOT NULL,
    description VARCHAR(255) NOT NULL,
    category VARCHAR(50) DEFAULT 'CAMPUS',
    member_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS space_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    space_id UUID REFERENCES spaces(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(50) NOT NULL,
    details TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID REFERENCES users(id) ON DELETE CASCADE,
    blocked_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_block_pair UNIQUE(blocker_id, blocked_user_id)
);

-- Pre-seed Greater Noida Themed Spaces
INSERT INTO spaces (name, slug, icon, description, category, member_count) VALUES
('Coding & Hackathons', 'coding-hackathons', '💻', 'LIET & Gr. Noida devs, leetcode grinders & hackathon squads', 'TECH', 84),
('Gym & Fitness', 'gym-fitness', '🏋️', 'Workout partners, PR checks & morning runs at Knowledge Park', 'FITNESS', 112),
('Indie & Live Music', 'indie-music', '🎧', 'Spotify blend swaps, concert buddies & campus jamming sessions', 'MUSIC', 95),
('Gaming & Esports', 'gaming-esports', '🎮', 'Valorant 5-stacks, BGMI custom rooms & Steam co-op', 'GAMING', 140),
('Books & Cafe Crawls', 'books-cafes', '📚', 'Exploring Sector 104 Noida cafes & peaceful library corners', 'LIFESTYLE', 67),
('Late Night Foodies', 'late-night-food', '🍕', 'Paratha corners, Maggi points & highway late-night chai runs', 'FOOD', 128)
ON CONFLICT (slug) DO NOTHING;

-- Pre-seed some initial community posts
INSERT INTO space_posts (space_id, user_id, content)
SELECT 
    s.id,
    u.id,
    CASE 
        WHEN s.slug = 'coding-hackathons' THEN 'Anyone building for the upcoming Smart India Hackathon? Need a frontend Flutter dev!'
        WHEN s.slug = 'gym-fitness' THEN 'Anyone hitting the gym near Knowledge Park 2 around 6 PM today?'
        WHEN s.slug = 'indie-music' THEN 'Obsessed with the new Lifafa and Prateek Kuhad tracks. Any fellow listeners at LIET?'
        WHEN s.slug = 'books-cafes' THEN 'Roastery Coffee House in Sector 144 is elite for study dates. Who has been there?'
    END
FROM spaces s
CROSS JOIN users u
WHERE u.phone_number = '9811111111' -- Ananya Verma
  AND s.slug IN ('coding-hackathons', 'gym-fitness', 'indie-music', 'books-cafes')
ON CONFLICT DO NOTHING;
