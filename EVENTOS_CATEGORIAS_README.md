# Relación Muchos a Muchos: Eventos y Categorías

## Estructura de la Base de Datos

La aplicación utiliza una relación muchos a muchos entre eventos y categorías mediante una tabla puente:

### Tablas Principales

1. **`events`** - Tabla principal de eventos
2. **`event_categories`** - Tabla de categorías disponibles
3. **`event_category_assignments`** - Tabla puente para la relación muchos a muchos

### Relaciones

```
events ←→ event_category_assignments ←→ event_categories
```

- Un evento puede tener múltiples categorías
- Una categoría puede ser asignada a múltiples eventos
- La tabla puente `event_category_assignments` conecta eventos con categorías

## Consultas Correctas

### 1. Obtener Eventos con sus Categorías

```dart
final response = await supabase
  .from('events')
  .select('''
    *,
    user_profiles!author_id(full_name),
    event_category_assignments!inner(
      event_categories!inner(id, name, color_code, icon_name)
    )
  ''')
  .eq('status', 'active')
  .order('event_date', ascending: true);
```

### 2. Procesar las Categorías

```dart
final categories = json['event_category_assignments'] != null 
    ? (json['event_category_assignments'] as List)
        .map((assignment) => assignment['event_categories']['name'] as String)
        .toList()
    : <String>[];
```

### 3. SQL Equivalente

La consulta anterior es equivalente a este SQL:

```sql
SELECT e.*, up.full_name, ec.name as category_name
FROM events e
LEFT JOIN user_profiles up ON e.author_id = up.id
LEFT JOIN event_category_assignments eca ON e.id = eca.event_id
LEFT JOIN event_categories ec ON eca.category_id = ec.id
WHERE e.status = 'active'
ORDER BY e.event_date ASC;
```

## Ejemplos de Uso

### Obtener Eventos de una Categoría Específica

```dart
final response = await supabase
  .from('events')
  .select('''
    *,
    user_profiles!author_id(full_name),
    event_category_assignments!inner(
      event_categories!inner(id, name, color_code, icon_name)
    )
  ''')
  .eq('status', 'active')
  .eq('event_category_assignments.event_categories.name', 'Talleres')
  .order('event_date', ascending: true);
```

### Crear Evento y Asignar Categorías

```dart
// 1. Crear el evento
final eventResponse = await supabase
  .from('events')
  .insert(eventData)
  .select()
  .single();

final eventId = eventResponse['id'];

// 2. Obtener IDs de categorías
final categoriesResponse = await supabase
  .from('event_categories')
  .select('id')
  .in_('name', ['Talleres', 'Tecnología']);

// 3. Asignar categorías al evento
final assignments = categoriesResponse
  .map((category) => {
        'event_id': eventId,
        'category_id': category['id'],
      })
  .toList();

await supabase
  .from('event_category_assignments')
  .insert(assignments);
```

## Diferencias con la Implementación Anterior

### ❌ Incorrecto (Anterior)
```dart
// Esto NO funciona porque no existe una relación directa
event_categories!inner(
  post_categories!inner(id, name, color_code, icon_name)
)
```

### ✅ Correcto (Actual)
```dart
// Esto SÍ funciona usando la tabla puente
event_category_assignments!inner(
  event_categories!inner(id, name, color_code, icon_name)
)
```

## Ventajas de esta Estructura

1. **Flexibilidad**: Un evento puede tener múltiples categorías
2. **Escalabilidad**: Fácil agregar nuevas categorías sin modificar eventos
3. **Normalización**: Evita duplicación de datos
4. **Consultas Eficientes**: Permite filtros complejos por categorías

## Archivos Modificados

- `lib/services/events_service.dart` - Servicio principal actualizado
- `lib/services/events_query_examples.dart` - Ejemplos de consultas
- `lib/models/event.dart` - Modelo de evento (ya estaba correcto)

## Políticas RLS (Row Level Security)

### Tablas con RLS Habilitado

1. **`events`** - Lectura pública, escritura solo para admins
2. **`event_categories`** - Lectura pública, escritura solo para admins  
3. **`event_category_assignments`** - Lectura pública, escritura solo para admins
4. **`event_registrations`** - Usuarios gestionan sus propios registros, admins pueden ver todos

### Políticas Implementadas

#### Events
- **`public_can_read_events`**: Lectura pública de eventos activos
- **`admins_manage_events`**: Admins pueden crear, editar y eliminar eventos

#### Event Categories
- **`public_can_read_event_categories`**: Lectura pública de categorías
- **`admins_manage_event_categories`**: Solo admins pueden gestionar categorías

#### Event Category Assignments
- **`public_can_read_event_category_assignments`**: Lectura pública de asignaciones
- **`admins_manage_event_category_assignments`**: Solo admins pueden asignar categorías

#### Event Registrations
- **`users_manage_own_event_registrations`**: Usuarios gestionan sus propios registros
- **`admins_can_read_all_event_registrations`**: Admins pueden ver todos los registros

## Notas Importantes

1. **Siempre usar la tabla puente**: Nunca intentar relacionar eventos directamente con categorías
2. **Procesar arrays**: Las categorías vienen como array de objetos de asignación
3. **Manejar casos nulos**: Algunos eventos pueden no tener categorías asignadas
4. **Usar `!inner` vs `!left`**: 
   - `!inner`: Solo eventos que tienen categorías
   - `!left`: Todos los eventos, incluso sin categorías
5. **Permisos de usuario**: Solo usuarios autenticados pueden registrarse en eventos
6. **Permisos de admin**: Solo administradores pueden crear/editar eventos y categorías
