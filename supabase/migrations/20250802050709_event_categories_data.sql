-- Location: supabase/migrations/20250802050709_event_categories_data.sql
-- Description: Insert sample event categories data

-- Insertar categorías de eventos de ejemplo
INSERT INTO event_categories (name, description, color_code, icon_name, is_system_category) VALUES
('Talleres', 'Talleres prácticos y sesiones de aprendizaje', '#3B82F6', 'build', true),
('Conferencias', 'Conferencias y charlas académicas', '#EF4444', 'mic', true),
('Ferias', 'Ferias de empleo y networking', '#F59E0B', 'store', true),
('Seminarios', 'Seminarios especializados', '#10B981', 'school', true),
('Networking', 'Eventos de networking y conexión', '#8B5CF6', 'people', true),
('Cultural', 'Eventos culturales y artísticos', '#EC4899', 'palette', true),
('Tecnología', 'Eventos relacionados con tecnología', '#06B6D4', 'computer', true),
('Deportes', 'Eventos deportivos y recreativos', '#84CC16', 'sports_soccer', true),
('Académico', 'Eventos académicos y educativos', '#6366F1', 'library_books', true),
('Social', 'Eventos sociales y comunitarios', '#F97316', 'celebration', true);

-- Verificar la inserción
SELECT 'Event categories data inserted successfully' as message;
SELECT name, description, color_code FROM event_categories ORDER BY name;
