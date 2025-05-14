# Health Pass - Supabase Integration

## Overview
This Flutter application has been integrated with Supabase to store user health data securely in the cloud. The app allows users to track their medical conditions, medications, and other health-related information.

## Setup Instructions

### 1. Supabase Configuration

Before running the application, you need to configure your Supabase credentials:

1. Open `lib/services/supabase_service.dart`
2. Replace the placeholder values with your actual Supabase credentials:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL', // Replace with your Supabase URL
     anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Supabase anon key
   );
   ```

### 2. Supabase Database Setup

Create the following tables in your Supabase database:

#### other_factors
```sql
CREATE TABLE other_factors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  factors JSONB NOT NULL,
  details TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES auth.users (id)
);
```

#### medications
```sql
CREATE TABLE medications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  medication TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES auth.users (id)
);
```

#### comments
```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  comment TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES auth.users (id)
);
```

#### conditions
```sql
CREATE TABLE conditions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  conditions JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES auth.users (id)
);
```

### 3. Row Level Security (RLS) Policies

For security, add these RLS policies to each table:

```sql
-- Enable RLS
ALTER TABLE other_factors ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE conditions ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own data" ON other_factors
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data" ON other_factors
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own data" ON other_factors
  FOR UPDATE USING (auth.uid() = user_id);
```

Repeat similar policies for the other tables.

## Features

- **Local Storage**: All data is stored locally using SharedPreferences
- **Cloud Sync**: Data is synchronized with Supabase when the user saves information
- **Offline Support**: Users can continue using the app offline, and data will sync when connectivity is restored
