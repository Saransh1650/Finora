-- Portfolio AI Supabase Schema
-- This schema creates user-scoped tables for stocks and portfolio analysis

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create users table (if using custom user management)
-- Note: If using Supabase Auth, the auth.users table already exists
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create stocks table
CREATE TABLE public.stocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  symbol TEXT NOT NULL,
  portfolio_percentage DECIMAL(5,2),
  sector TEXT,
  profit_loss_percentage DECIMAL(8,2),
  sector_rank INTEGER,
  avg_price DECIMAL(12,2),
  last_trading_price DECIMAL(12,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create portfolio_analysis table
CREATE TABLE public.portfolio_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  portfolio_summary JSONB,
  stocks JSONB,
  rebalancing_plan JSONB,
  analysis_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_stocks_user_id ON public.stocks(user_id);
CREATE INDEX idx_stocks_symbol ON public.stocks(symbol);
CREATE INDEX idx_portfolio_analysis_user_id ON public.portfolio_analysis(user_id);
CREATE INDEX idx_portfolio_analysis_date ON public.portfolio_analysis(analysis_date);

-- Enable Row Level Security (RLS)
ALTER TABLE public.stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_analysis ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for stocks table
CREATE POLICY "Users can view their own stocks" ON public.stocks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stocks" ON public.stocks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own stocks" ON public.stocks
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own stocks" ON public.stocks
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for portfolio_analysis table
CREATE POLICY "Users can view their own portfolio analysis" ON public.portfolio_analysis
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own portfolio analysis" ON public.portfolio_analysis
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own portfolio analysis" ON public.portfolio_analysis
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own portfolio analysis" ON public.portfolio_analysis
  FOR DELETE USING (auth.uid() = user_id);

-- Create functions for updated_at timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER handle_stocks_updated_at
  BEFORE UPDATE ON public.stocks
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_portfolio_analysis_updated_at
  BEFORE UPDATE ON public.portfolio_analysis
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();