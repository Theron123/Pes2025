-- Migration: Create notifications table
-- Date: 2024-01-XX
-- Description: Notifications table for the hospital massage system

-- Create notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    appointment_id UUID REFERENCES appointments(id),
    scheduled_for TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_appointment_id ON notifications(appointment_id);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Create function to mark notifications as read
CREATE OR REPLACE FUNCTION mark_notifications_as_read(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE notifications 
    SET read = true 
    WHERE user_id = user_uuid AND read = false;
END;
$$ LANGUAGE plpgsql;

-- Create function to clean old notifications
CREATE OR REPLACE FUNCTION clean_old_notifications()
RETURNS VOID AS $$
BEGIN
    DELETE FROM notifications 
    WHERE created_at < NOW() - INTERVAL '6 months';
END;
$$ LANGUAGE plpgsql;

-- Descriptive comments in English
COMMENT ON TABLE notifications IS 'Notifications table for the hospital massage system';
COMMENT ON COLUMN notifications.user_id IS 'User recipient of the notification';
COMMENT ON COLUMN notifications.type IS 'Notification type: appointment_confirmed, reminder, cancellation, etc.';
COMMENT ON COLUMN notifications.title IS 'Notification title';
COMMENT ON COLUMN notifications.message IS 'Complete notification message';
COMMENT ON COLUMN notifications.read IS 'Indicates if the notification has been read';
COMMENT ON COLUMN notifications.appointment_id IS 'Reference to related appointment (optional)';
COMMENT ON COLUMN notifications.scheduled_for IS 'Scheduled date and time for sending';
COMMENT ON COLUMN notifications.sent_at IS 'Date and time when the notification was sent'; 