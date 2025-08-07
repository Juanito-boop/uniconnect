-- Location: supabase/migrations/20250802050710_event_registration_counts.sql
-- Description: Create function to get event registration counts

-- Función para obtener el conteo de registros por evento
CREATE OR REPLACE FUNCTION get_event_registration_counts(event_ids UUID[])
RETURNS TABLE(event_id UUID, count BIGINT)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 
    er.event_id,
    COUNT(*) as count
  FROM event_registrations er
  WHERE er.event_id = ANY(event_ids)
  GROUP BY er.event_id;
$$;
