import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/events_service.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _registrationUrlController = TextEditingController();
  final _agendaUrlController = TextEditingController();
  final _meetingUrlController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _speakersController = TextEditingController();

  List<EventCategory> _categories = [];
  List<String> _selectedCategoryIds = [];
  EventType _selectedEventType = EventType.general;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isOnline = false;
  bool _requiresRegistration = false;
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  // Removed unused _error field after localization refactor

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _registrationUrlController.dispose();
    _agendaUrlController.dispose();
    _meetingUrlController.dispose();
    _maxAttendeesController.dispose();
    _speakersController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndLoadData() async {
    try {
      final isAdmin = await AuthService.instance.isCurrentUserAdmin();
      if (!isAdmin) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.t('adminOnlyEvents')),
            backgroundColor: Colors.red,
          ));
          Navigator.pop(context);
        }
        return;
      }

      await _loadCategories();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
      });

      final categories = await EventsService.instance.getEventCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.t('pleaseSelectDateTime')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final eventDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final speakers = _speakersController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await EventsService.instance.createEvent(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        eventDate: eventDate,
        location: _locationController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        registrationUrl: _registrationUrlController.text.trim().isEmpty
            ? null
            : _registrationUrlController.text.trim(),
        maxAttendees: int.tryParse(_maxAttendeesController.text) ?? 0,
        eventType: _selectedEventType,
        requiresRegistration: _requiresRegistration,
        speakers: speakers,
        agendaUrl: _agendaUrlController.text.trim().isEmpty
            ? null
            : _agendaUrlController.text.trim(),
        isOnline: _isOnline,
        meetingUrl: _meetingUrlController.text.trim().isEmpty
            ? null
            : _meetingUrlController.text.trim(),
        categoryIds:
            _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.t('eventCreatedSuccess')),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n.t('eventCreateErrorPrefix')} $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Widget _buildEventTypesSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('eventTypeLabel'),
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: EventType.values.map((type) {
              return ChoiceChip(
                label: Text(type.displayName),
                selected: _selectedEventType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedEventType = type;
                  });
                },
                selectedColor: type.color.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _selectedEventType == type
                      ? type.color
                      : Colors.grey[700],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (_isLoadingCategories) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('categoriesOptional'),
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _categories.map((category) {
              final isSelected = _selectedCategoryIds.contains(category.id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategoryIds.remove(category.id);
                    } else {
                      _selectedCategoryIds.add(category.id);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        category.name,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).t('eventCreateAppBar'),
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createEvent,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context).t('eventCreateAction'),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).t('eventTitleLabel'),
                    hintText: AppLocalizations.of(context).t('eventTitleHint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)
                          .t('eventTitleRequired');
                    }
                    if (value.trim().length < 5) {
                      return AppLocalizations.of(context).t('eventTitleMin');
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 3.h),

              // Content field
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).t('eventDescriptionLabel'),
                    hintText:
                        AppLocalizations.of(context).t('eventDescriptionHint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)
                          .t('eventDescriptionRequired');
                    }
                    if (value.trim().length < 20) {
                      return AppLocalizations.of(context)
                          .t('eventDescriptionMin');
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 3.h),

              // Event type
              _buildEventTypesSection(),

              SizedBox(height: 3.h),

              // Date and time picker
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedDate == null || _selectedTime == null
                        ? AppLocalizations.of(context).t('selectDateTime')
                        : '${DateFormat('MMM d, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _selectDateTime,
                ),
              ),

              SizedBox(height: 3.h),

              // Location
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).t('locationLabel'),
                        hintText:
                            AppLocalizations.of(context).t('locationHint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    SwitchListTile(
                      title:
                          Text(AppLocalizations.of(context).t('onlineEvent')),
                      value: _isOnline,
                      onChanged: (value) {
                        setState(() {
                          _isOnline = value;
                        });
                      },
                    ),
                    if (_isOnline)
                      TextFormField(
                        controller: _meetingUrlController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).t('meetingUrlLabel'),
                          hintText:
                              AppLocalizations.of(context).t('meetingUrlHint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.link),
                        ),
                        validator: (value) {
                          if (_isOnline &&
                              (value == null || value.trim().isEmpty)) {
                            return AppLocalizations.of(context)
                                .t('meetingUrlRequired');
                          }
                          return null;
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Categories
              _buildCategoriesSection(),

              SizedBox(height: 3.h),

              // Additional settings
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).t('additionalDetails'),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _maxAttendeesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).t('maxAttendeesLabel'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.people),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _speakersController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).t('speakersLabel'),
                        hintText:
                            AppLocalizations.of(context).t('speakersHint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.mic),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)
                          .t('requiresRegistration')),
                      value: _requiresRegistration,
                      onChanged: (value) {
                        setState(() {
                          _requiresRegistration = value;
                        });
                      },
                    ),
                    if (_requiresRegistration)
                      TextFormField(
                        controller: _registrationUrlController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .t('registrationUrlLabel'),
                          hintText: AppLocalizations.of(context)
                              .t('registrationUrlHint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.app_registration),
                        ),
                      ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .t('imageUrlEventLabel'),
                        hintText:
                            AppLocalizations.of(context).t('imageUrlEventHint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.image),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: _agendaUrlController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).t('agendaUrlLabel'),
                        hintText:
                            AppLocalizations.of(context).t('agendaUrlHint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Create event button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).t('eventCreateAppBar'),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
