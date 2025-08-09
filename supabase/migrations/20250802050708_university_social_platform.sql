-- Location: supabase/migrations/20250802050708_university_social_platform.sql
-- Schema Analysis: Fresh project - no existing schema
-- Module: University Social Platform (Twitter-like for universities)
-- Dependencies: Creates complete authentication and post management system

-- 1. Extensions & Types
CREATE TYPE public.user_role AS ENUM ('student', 'admin');
CREATE TYPE public.post_status AS ENUM ('active', 'archived', 'draft');

-- 2. Core Tables
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'student'::public.user_role,
    university_id TEXT DEFAULT 'default_uni',
    department TEXT,
    student_id TEXT,
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP),
    updated_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP)
);

CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    status public.post_status DEFAULT 'active'::public.post_status,
    is_featured BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP),
    updated_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP)
);

CREATE TABLE public.post_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    color_code TEXT DEFAULT '#3B82F6',
    is_system_category BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP)
);

CREATE TABLE public.post_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP),
    UNIQUE(post_id, user_id)
);

-- Junction table for post categories
CREATE TABLE public.post_category_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.post_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT timezone('America/Bogota', CURRENT_TIMESTAMP),
    UNIQUE(post_id, category_id)
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_university ON public.user_profiles(university_id);
CREATE INDEX idx_posts_author_id ON public.posts(author_id);
CREATE INDEX idx_posts_status ON public.posts(status);
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX idx_posts_featured ON public.posts(is_featured) WHERE is_featured = true;
CREATE INDEX idx_post_likes_post_id ON public.post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON public.post_likes(user_id);
CREATE INDEX idx_post_category_assignments_post_id ON public.post_category_assignments(post_id);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'student'::public.user_role)
  );  
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_post_like_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.posts 
        SET like_count = like_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.posts 
        SET like_count = like_count - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

-- 5. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_category_assignments ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Using Pattern 1 for user_profiles, Pattern 4 for posts)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for posts
CREATE POLICY "public_can_read_posts"
ON public.posts
FOR SELECT
TO public
USING (status = 'active'::public.post_status);

CREATE POLICY "admins_manage_all_posts"
ON public.posts
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 4: Public read for categories
CREATE POLICY "public_can_read_categories"
ON public.post_categories
FOR SELECT
TO public
USING (true);

CREATE POLICY "admins_manage_categories"
ON public.post_categories
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for likes
CREATE POLICY "users_manage_own_likes"
ON public.post_likes
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for category assignments
CREATE POLICY "public_can_read_assignments"
ON public.post_category_assignments
FOR SELECT
TO public
USING (true);

CREATE POLICY "admins_manage_assignments"
ON public.post_category_assignments
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_like_count_trigger
  AFTER INSERT OR DELETE ON public.post_likes
  FOR EACH ROW EXECUTE FUNCTION public.update_post_like_count();

-- Select statement to verify data
SELECT 'University social platform created successfully, sample records:' as message;
SELECT p.title, p.content, up.full_name as author, p.created_at 
FROM public.posts p 
JOIN public.user_profiles up ON p.author_id = up.id 
LIMIT 3;

CREATE TABLE IF NOT EXISTS events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  image_url VARCHAR(500),
  author_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  location VARCHAR(255) NOT NULL,
  registration_url VARCHAR(500),
  max_attendees INTEGER DEFAULT 0,
  event_type VARCHAR(255) NOT NULL DEFAULT 'general',
  requires_registration BOOLEAN DEFAULT false,
  speakers TEXT[],
  agenda_url VARCHAR(500),
  is_online BOOLEAN DEFAULT false,
  meeting_url VARCHAR(500),
  is_featured BOOLEAN DEFAULT false,
  status VARCHAR(20) DEFAULT 'active',
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_events_event_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_author_id ON events(author_id);
CREATE INDEX IF NOT EXISTS idx_events_event_type ON events(event_type);

CREATE TABLE IF NOT EXISTS event_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  color_code VARCHAR(7) DEFAULT '#3B82F6',
  icon_name VARCHAR(50),
  is_system_category BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla puente para categorías de eventos
CREATE TABLE IF NOT EXISTS event_category_assignments (
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  category_id UUID REFERENCES event_categories(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, category_id)
);

CREATE TABLE IF NOT EXISTS event_registrations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  attended BOOLEAN DEFAULT false,
  checked_in_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(event_id, user_id)
);

CREATE TYPE event_type AS ENUM (
  'conference',
  'fair', 
  'workshop',
  'seminar',
  'networking',
  'cultural',
  'general'
);