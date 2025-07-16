-- Migration: Create appointments table
-- Date: 2024-01-XX
-- Description: Appointments table for the hospital massage system

-- Create appointments table
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
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT
);

-- Create indexes for performance
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_therapist_id ON appointments(therapist_id);
CREATE INDEX idx_appointments_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, appointment_time);
CREATE INDEX idx_appointments_created_by ON appointments(created_by);

-- Create trigger to update updated_at
CREATE TRIGGER trigger_update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create constraint to prevent duplicate appointments
ALTER TABLE appointments ADD CONSTRAINT unique_appointment_therapist_date_time 
    UNIQUE (therapist_id, appointment_date, appointment_time);

-- Descriptive comments in English
COMMENT ON TABLE appointments IS 'Appointments table for the hospital massage system';
COMMENT ON COLUMN appointments.patient_id IS 'Reference to the patient user';
COMMENT ON COLUMN appointments.therapist_id IS 'Reference to the assigned therapist';
COMMENT ON COLUMN appointments.appointment_date IS 'Date of the appointment';
COMMENT ON COLUMN appointments.appointment_time IS 'Time of the appointment';
COMMENT ON COLUMN appointments.duration_minutes IS 'Duration of the appointment in minutes';
COMMENT ON COLUMN appointments.massage_type IS 'Type of massage to be performed';
COMMENT ON COLUMN appointments.status IS 'Appointment status: pending, confirmed, in_progress, completed, cancelled, no_show';
COMMENT ON COLUMN appointments.notes IS 'Additional notes about the appointment';
COMMENT ON COLUMN appointments.created_by IS 'User who created the appointment';
COMMENT ON COLUMN appointments.cancellation_reason IS 'Reason for cancellation if applicable'; 