-- Migration: Create therapists table
-- Date: 2024-01-XX
-- Description: Therapists table for the hospital massage system

-- Create therapists table
CREATE TABLE therapists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    specializations TEXT[],
    available BOOLEAN DEFAULT true,
    work_schedule JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_therapists_user_id ON therapists(user_id);
CREATE INDEX idx_therapists_license_number ON therapists(license_number);
CREATE INDEX idx_therapists_available ON therapists(available);
CREATE INDEX idx_therapists_specializations ON therapists USING GIN(specializations);

-- Create trigger to update updated_at
CREATE TRIGGER trigger_update_therapists_updated_at
    BEFORE UPDATE ON therapists
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Descriptive comments in English
COMMENT ON TABLE therapists IS 'Certified therapists table for the hospital massage system';
COMMENT ON COLUMN therapists.user_id IS 'Reference to the associated user';
COMMENT ON COLUMN therapists.license_number IS 'Unique professional license number of the therapist';
COMMENT ON COLUMN therapists.specializations IS 'Array of therapist specializations (Swedish, Deep Tissue, etc.)';
COMMENT ON COLUMN therapists.available IS 'Indicates if the therapist is available for appointments';
COMMENT ON COLUMN therapists.work_schedule IS 'Work schedule of the therapist in JSON format'; 