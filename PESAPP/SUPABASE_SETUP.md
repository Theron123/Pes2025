# Supabase Setup Guide for Hospital Massage System

## Overview
This document outlines the steps required to set up Supabase for the Hospital Massage System.

## Prerequisites
- Supabase account (https://supabase.com)
- Access to MCP Supabase tools
- Environment variables configuration

## 1. Project Creation

### Using MCP Tools (Recommended)
```bash
# Set your access token first
export SUPABASE_ACCESS_TOKEN=your_access_token_here

# Create a new project (when available)
mcp_supabase_create_project --name "hospital-massage-system"
```

### Manual Setup
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Name: "Hospital Massage System"
4. Organization: Your organization
5. Database Password: Generate strong password
6. Region: Choose closest to your users

## 2. Environment Configuration

### Update API Constants
Update `lib/app/constants/api_constants.dart` with your actual Supabase credentials:

```dart
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

### Environment Variables (Production)
```bash
# Add to your CI/CD or deployment environment
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

## 3. Database Schema Setup

### Using MCP Tools
```bash
# Create users table
mcp_supabase_apply_migration --name "create_users_table" --query "
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'patient',
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    requires_2fa BOOLEAN DEFAULT false,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);"

# Create therapists table
mcp_supabase_apply_migration --name "create_therapists_table" --query "
CREATE TABLE therapists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    specializations TEXT[],
    is_available BOOLEAN DEFAULT true,
    working_hours JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);"

# Create appointments table
mcp_supabase_apply_migration --name "create_appointments_table" --query "
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES therapists(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    massage_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    canceled_at TIMESTAMP WITH TIME ZONE,
    canceled_by UUID REFERENCES users(id),
    cancellation_reason TEXT
);"

# Create audit logs table
mcp_supabase_apply_migration --name "create_audit_logs_table" --query "
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);"

# Create notifications table
mcp_supabase_apply_migration --name "create_notifications_table" --query "
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    appointment_id UUID REFERENCES appointments(id),
    scheduled_for TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);"
```

## 4. Row Level Security (RLS) Setup

```bash
# Apply RLS policies
mcp_supabase_apply_migration --name "setup_rls_policies" --query "
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE therapists ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY 'Users can view own profile' ON users
FOR SELECT USING (auth.uid() = id);

-- Admins can view all users
CREATE POLICY 'Admins can view all users' ON users
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Patients can only see their appointments
CREATE POLICY 'Patients can view own appointments' ON appointments
FOR SELECT USING (patient_id = auth.uid());

-- Therapists can see their assigned appointments
CREATE POLICY 'Therapists can view assigned appointments' ON appointments
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM therapists 
    WHERE user_id = auth.uid() AND id = appointments.therapist_id
  )
);
"
```

## 5. Storage Buckets Setup

```bash
# Create storage buckets (when MCP support is available)
# For now, create manually in Supabase dashboard:
# 1. Go to Storage section
# 2. Create bucket: "profile-images" (public: false)
# 3. Create bucket: "reports" (public: false)  
# 4. Create bucket: "system-files" (public: false)
```

## 6. Authentication Configuration

### Email Settings
1. Go to Authentication > Settings
2. Configure email templates
3. Enable email confirmation
4. Set up custom SMTP (optional)

### Two-Factor Authentication
1. Enable 2FA in Authentication settings
2. Configure allowed factors: TOTP
3. Set up MFA policies for admin/therapist roles

## 7. Edge Functions Setup

### Notification Reminder Function
```bash
mcp_supabase_deploy_edge_function --name "send-appointment-reminders" --files '[
  {
    "name": "index.ts", 
    "content": "..."
  }
]'
```

### Report Generation Function
```bash
mcp_supabase_deploy_edge_function --name "generate-report" --files '[
  {
    "name": "index.ts",
    "content": "..."
  }
]'
```

## 8. Testing Setup

```bash
# List all tables to verify setup
mcp_supabase_list_tables

# Check RLS policies
mcp_supabase_execute_sql --query "
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';"

# Test connection
mcp_supabase_execute_sql --query "SELECT version();"
```

## 9. Monitoring and Security

```bash
# Check security advisors
mcp_supabase_get_advisors --type "security"
mcp_supabase_get_advisors --type "performance"

# View logs
mcp_supabase_get_logs --service "api"
mcp_supabase_get_logs --service "postgres"
```

## 10. Development Workflow

### Branch Management
```bash
# Create development branch
mcp_supabase_create_branch --name "development"

# List branches
mcp_supabase_list_branches

# Merge to production when ready
mcp_supabase_merge_branch --branch_id "dev-branch-id"
```

## Security Checklist

- [ ] RLS policies enabled on all tables
- [ ] Proper role-based access control implemented
- [ ] 2FA enabled for admin/therapist accounts
- [ ] Email verification enabled
- [ ] Strong database password set
- [ ] Environment variables properly configured
- [ ] API keys secured
- [ ] Storage bucket permissions configured
- [ ] Audit logging enabled
- [ ] Regular security scans scheduled

## Status

- [x] Flutter client configuration created
- [x] Error handling implemented
- [x] Network connectivity utilities created
- [ ] **PENDING**: Actual Supabase project creation
- [ ] **PENDING**: Database schema migration
- [ ] **PENDING**: RLS policies setup
- [ ] **PENDING**: Storage buckets configuration
- [ ] **PENDING**: Edge functions deployment
- [ ] **PENDING**: Authentication configuration

## Next Steps

1. **Set up Supabase access token** for MCP tools
2. **Create Supabase project** using MCP or manual setup
3. **Configure environment variables** with actual credentials
4. **Run database migrations** to create schema
5. **Set up RLS policies** for security
6. **Configure authentication** settings
7. **Deploy Edge Functions** for automation
8. **Test end-to-end setup**

## Notes

- The Flutter client is already configured to work with Supabase
- Error handling and network utilities are implemented
- All database schema is defined and ready for migration
- The app will continue to work with placeholder data until Supabase is fully configured 