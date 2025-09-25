-- Portfolio AI Complete Database Schema
-- Run this in your Supabase SQL Editor to create the complete table structure
-- Including portfolio, chat system, and user management

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Create function for handling updated_at timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- USER MANAGEMENT
-- =============================================================================

-- Create users table (extends Supabase Auth)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- PORTFOLIO SYSTEM
-- =============================================================================

-- Create stocks table
CREATE TABLE IF NOT EXISTS public.stocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL,
  total_invested NUMERIC(15, 2) DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns to stocks table if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'stocks' AND column_name = 'created_at' AND table_schema = 'public') THEN
    ALTER TABLE public.stocks ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'stocks' AND column_name = 'updated_at' AND table_schema = 'public') THEN
    ALTER TABLE public.stocks ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
  END IF;
END $$;

-- Add missing columns to chat_conversations table if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'chat_conversations' AND column_name = 'session_context' AND table_schema = 'public') THEN
    ALTER TABLE public.chat_conversations ADD COLUMN session_context JSONB DEFAULT '{}'::jsonb;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'chat_conversations' AND column_name = 'session_id' AND table_schema = 'public') THEN
    ALTER TABLE public.chat_conversations ADD COLUMN session_id TEXT DEFAULT gen_random_uuid()::text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'chat_conversations' AND column_name = 'session_type' AND table_schema = 'public') THEN
    ALTER TABLE public.chat_conversations ADD COLUMN session_type TEXT DEFAULT 'chat' CHECK (session_type IN ('chat', 'analysis', 'planning', 'research'));
  END IF;
END $$;

-- Create portfolio_analysis table
CREATE TABLE IF NOT EXISTS public.portfolio_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  portfolio_summary_by_ai_model JSONB DEFAULT NULL,
  analysis_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- CHAT SYSTEM
-- =============================================================================

-- Create chat_conversations table
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'New Conversation',
  context_type TEXT DEFAULT 'general' CHECK (context_type IN ('general', 'portfolio', 'stock_analysis', 'market_insights')),
  session_context JSONB DEFAULT '{}'::jsonb,
  session_id TEXT DEFAULT gen_random_uuid()::text,
  session_type TEXT DEFAULT 'chat' CHECK (session_type IN ('chat', 'analysis', 'planning', 'research')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  metadata JSONB DEFAULT NULL,
  tokens_used INTEGER DEFAULT 0,
  processing_time_ms INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chat_attachments table
CREATE TABLE IF NOT EXISTS public.chat_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Portfolio indexes
CREATE INDEX IF NOT EXISTS idx_stocks_user_id ON public.stocks(user_id);
CREATE INDEX IF NOT EXISTS idx_stocks_symbol ON public.stocks(symbol);
CREATE INDEX IF NOT EXISTS idx_stocks_user_symbol ON public.stocks(user_id, symbol);
CREATE INDEX IF NOT EXISTS idx_portfolio_analysis_user_id ON public.portfolio_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_analysis_date ON public.portfolio_analysis(analysis_date DESC);

-- Chat indexes
CREATE INDEX IF NOT EXISTS idx_chat_conversations_user_id ON public.chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_updated_at ON public.chat_conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_active ON public.chat_conversations(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_session_id ON public.chat_conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_session_type ON public.chat_conversations(session_type);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id ON public.chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_created ON public.chat_messages(conversation_id, created_at);
CREATE INDEX IF NOT EXISTS idx_chat_attachments_message_id ON public.chat_attachments(message_id);

-- User indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_attachments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;

DROP POLICY IF EXISTS "Users can view their own stocks" ON public.stocks;
DROP POLICY IF EXISTS "Users can insert their own stocks" ON public.stocks;
DROP POLICY IF EXISTS "Users can update their own stocks" ON public.stocks;
DROP POLICY IF EXISTS "Users can delete their own stocks" ON public.stocks;

DROP POLICY IF EXISTS "Users can view their own portfolio analysis" ON public.portfolio_analysis;
DROP POLICY IF EXISTS "Users can insert their own portfolio analysis" ON public.portfolio_analysis;
DROP POLICY IF EXISTS "Users can update their own portfolio analysis" ON public.portfolio_analysis;
DROP POLICY IF EXISTS "Users can delete their own portfolio analysis" ON public.portfolio_analysis;

DROP POLICY IF EXISTS "Users can view their own conversations" ON public.chat_conversations;
DROP POLICY IF EXISTS "Users can insert their own conversations" ON public.chat_conversations;
DROP POLICY IF EXISTS "Users can update their own conversations" ON public.chat_conversations;
DROP POLICY IF EXISTS "Users can delete their own conversations" ON public.chat_conversations;

DROP POLICY IF EXISTS "Users can view messages from their conversations" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can insert messages to their conversations" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can update their own messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON public.chat_messages;

DROP POLICY IF EXISTS "Users can view attachments from their messages" ON public.chat_attachments;
DROP POLICY IF EXISTS "Users can insert attachments to their messages" ON public.chat_attachments;

-- Users table policies
CREATE POLICY "Users can view their own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Stocks table policies
CREATE POLICY "Users can view their own stocks" ON public.stocks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stocks" ON public.stocks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own stocks" ON public.stocks
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own stocks" ON public.stocks
  FOR DELETE USING (auth.uid() = user_id);

-- Portfolio analysis table policies
CREATE POLICY "Users can view their own portfolio analysis" ON public.portfolio_analysis
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own portfolio analysis" ON public.portfolio_analysis
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own portfolio analysis" ON public.portfolio_analysis
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own portfolio analysis" ON public.portfolio_analysis
  FOR DELETE USING (auth.uid() = user_id);

-- Chat conversations table policies
CREATE POLICY "Users can view their own conversations" ON public.chat_conversations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own conversations" ON public.chat_conversations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own conversations" ON public.chat_conversations
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own conversations" ON public.chat_conversations
  FOR DELETE USING (auth.uid() = user_id);

-- Chat messages table policies
CREATE POLICY "Users can view messages from their conversations" ON public.chat_messages
  FOR SELECT USING (
    auth.uid() = user_id OR 
    EXISTS (
      SELECT 1 FROM public.chat_conversations 
      WHERE id = conversation_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert messages to their conversations" ON public.chat_messages
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM public.chat_conversations 
      WHERE id = conversation_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own messages" ON public.chat_messages
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own messages" ON public.chat_messages
  FOR DELETE USING (auth.uid() = user_id);

-- Chat attachments table policies
CREATE POLICY "Users can view attachments from their messages" ON public.chat_attachments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.chat_messages cm
      JOIN public.chat_conversations cc ON cm.conversation_id = cc.id
      WHERE cm.id = message_id AND cc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert attachments to their messages" ON public.chat_attachments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.chat_messages cm
      JOIN public.chat_conversations cc ON cm.conversation_id = cc.id
      WHERE cm.id = message_id AND cc.user_id = auth.uid()
    )
  );

-- =============================================================================
-- TRIGGERS
-- =============================================================================

-- Drop existing triggers and functions if they exist
DROP TRIGGER IF EXISTS users_updated_at_trigger ON public.users;
DROP TRIGGER IF EXISTS stocks_updated_at_trigger ON public.stocks;
DROP TRIGGER IF EXISTS portfolio_analysis_updated_at_trigger ON public.portfolio_analysis;
DROP TRIGGER IF EXISTS chat_conversations_updated_at_trigger ON public.chat_conversations;
DROP TRIGGER IF EXISTS chat_message_update_conversation_trigger ON public.chat_messages;
DROP TRIGGER IF EXISTS chat_message_generate_title_trigger ON public.chat_messages;

-- Updated_at triggers for all tables with timestamps
CREATE TRIGGER users_updated_at_trigger
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER stocks_updated_at_trigger
  BEFORE UPDATE ON public.stocks
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER portfolio_analysis_updated_at_trigger
  BEFORE UPDATE ON public.portfolio_analysis
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER chat_conversations_updated_at_trigger
  BEFORE UPDATE ON public.chat_conversations
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Chat-specific triggers
-- Update conversation timestamp when new message is added
CREATE OR REPLACE FUNCTION public.update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.chat_conversations 
  SET updated_at = NOW()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chat_message_update_conversation_trigger
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_conversation_timestamp();

-- Auto-generate conversation titles based on first message
CREATE OR REPLACE FUNCTION public.generate_conversation_title()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'user' AND 
     EXISTS (
       SELECT 1 FROM public.chat_conversations 
       WHERE id = NEW.conversation_id 
       AND title = 'New Conversation'
     ) THEN
    UPDATE public.chat_conversations 
    SET title = CASE 
      WHEN LENGTH(NEW.content) > 50 
      THEN LEFT(NEW.content, 47) || '...'
      ELSE NEW.content
    END
    WHERE id = NEW.conversation_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chat_message_generate_title_trigger
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_conversation_title();

-- =============================================================================
-- SESSION MANAGEMENT FUNCTIONS
-- =============================================================================

-- Drop the old function signature if it exists (with portfolio context parameter)
DROP FUNCTION IF EXISTS public.create_new_chat_session(UUID, TEXT, TEXT, TEXT, BOOLEAN, JSONB);

-- Function to create a new chat session with proper defaults
CREATE OR REPLACE FUNCTION public.create_new_chat_session(
  p_user_id UUID,
  p_title TEXT DEFAULT 'New Conversation',
  p_context_type TEXT DEFAULT 'general',
  p_session_type TEXT DEFAULT 'chat',
  p_initial_session_context JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
  v_conversation_id UUID;
BEGIN
  -- Create the conversation
  INSERT INTO public.chat_conversations (
    user_id,
    title,
    context_type,
    session_context,
    session_type,
    is_active
  ) VALUES (
    p_user_id,
    p_title,
    p_context_type,
    p_initial_session_context,
    p_session_type,
    true
  ) RETURNING id INTO v_conversation_id;

  RETURN v_conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update session context
CREATE OR REPLACE FUNCTION public.update_session_context(
  p_conversation_id UUID,
  p_context_updates JSONB
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.chat_conversations 
  SET session_context = session_context || p_context_updates,
      updated_at = NOW()
  WHERE id = p_conversation_id
    AND user_id = auth.uid();
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- VIEWS
-- =============================================================================

-- Drop existing views if they exist
DROP VIEW IF EXISTS public.conversation_summaries;
DROP VIEW IF EXISTS public.portfolio_summary;

-- Conversation summaries view for listing conversations
CREATE OR REPLACE VIEW public.conversation_summaries AS
SELECT 
  cc.id,
  cc.user_id,
  cc.title,
  cc.context_type,
  cc.session_context,
  cc.session_id,
  cc.session_type,
  cc.is_active,
  cc.created_at,
  cc.updated_at,
  COUNT(cm.id) as message_count,
  MAX(cm.created_at) as last_message_at,
  COALESCE(
    (SELECT content FROM public.chat_messages 
     WHERE conversation_id = cc.id 
     ORDER BY created_at DESC 
     LIMIT 1), 
    ''
  ) as last_message_preview
FROM public.chat_conversations cc
LEFT JOIN public.chat_messages cm ON cc.id = cm.conversation_id
GROUP BY cc.id, cc.user_id, cc.title, cc.context_type, cc.session_context, cc.session_id, cc.session_type, cc.is_active, cc.created_at, cc.updated_at
ORDER BY cc.updated_at DESC;

-- Portfolio summary view
CREATE OR REPLACE VIEW public.portfolio_summary AS
SELECT 
  s.user_id,
  COUNT(s.id) as total_stocks,
  SUM(s.total_invested) as total_invested,
  SUM(s.quantity) as total_quantity,
  ARRAY_AGG(s.symbol ORDER BY s.total_invested DESC) as top_stocks,
  MAX(COALESCE(s.updated_at, s.created_at)) as last_updated
FROM public.stocks s
GROUP BY s.user_id;

-- =============================================================================
-- PERMISSIONS
-- =============================================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Tables
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.stocks TO authenticated;
GRANT ALL ON public.portfolio_analysis TO authenticated;
GRANT ALL ON public.chat_conversations TO authenticated;
GRANT ALL ON public.chat_messages TO authenticated;
GRANT ALL ON public.chat_attachments TO authenticated;

-- Functions
GRANT EXECUTE ON FUNCTION public.create_new_chat_session(UUID, TEXT, TEXT, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_session_context(UUID, JSONB) TO authenticated;

-- Views
GRANT SELECT ON public.conversation_summaries TO authenticated, anon;
GRANT SELECT ON public.portfolio_summary TO authenticated, anon;

-- Read-only access for anon users (optional, remove if not needed)
GRANT SELECT ON public.users TO anon;
GRANT SELECT ON public.stocks TO anon;
GRANT SELECT ON public.portfolio_analysis TO anon;
GRANT SELECT ON public.chat_conversations TO anon;
GRANT SELECT ON public.chat_messages TO anon;
GRANT SELECT ON public.chat_attachments TO anon;

-- =============================================================================
-- COMPLETION
-- =============================================================================

-- Confirm schema creation
SELECT 'Complete Portfolio AI schema applied successfully!' as status,
       'Tables: users, stocks, portfolio_analysis, chat_conversations, chat_messages, chat_attachments' as tables_created,
       'Views: conversation_summaries, portfolio_summary' as views_created,
       'RLS enabled on all tables with appropriate policies' as security;
