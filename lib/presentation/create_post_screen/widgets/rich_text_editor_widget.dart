import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RichTextEditorWidget extends StatefulWidget {
  final String content;
  final Function(String) onContentChanged;
  final int maxCharacters;

  const RichTextEditorWidget({
    Key? key,
    required this.content,
    required this.onContentChanged,
    this.maxCharacters = 500,
  }) : super(key: key);

  @override
  State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
}

class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isBold = false;
  bool _isItalic = false;
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _showToolbar = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.length <= widget.maxCharacters) {
      widget.onContentChanged(value);
    }
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (context) => _LinkDialog(
        onLinkInserted: (link) {
          final currentText = _controller.text;
          final selection = _controller.selection;
          final newText = currentText.replaceRange(
            selection.start,
            selection.end,
            link,
          );
          _controller.text = newText;
          _controller.selection = TextSelection.collapsed(
            offset: selection.start + link.length,
          );
          _onTextChanged(newText);
        },
      ),
    );
  }

  Color get _characterCountColor {
    final remaining = widget.maxCharacters - _controller.text.length;
    if (remaining < 50) return AppTheme.lightTheme.colorScheme.error;
    if (remaining < 100) return Color(0xFFF59E0B);
    return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showToolbar) _buildToolbar(),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 5,
                  maxLength: widget.maxCharacters,
                  onChanged: _onTextChanged,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Escribe tu anuncio aquí...\n\nComparte información importante sobre eventos del campus, actividades académicas, o noticias relevantes para la comunidad universitaria.',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Contenido del post',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_controller.text.length}/${widget.maxCharacters}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _characterCountColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Formato:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 3.w),
          _buildToolbarButton(
            icon: 'format_bold',
            isActive: _isBold,
            onTap: _toggleBold,
            tooltip: 'Negrita',
          ),
          SizedBox(width: 2.w),
          _buildToolbarButton(
            icon: 'format_italic',
            isActive: _isItalic,
            onTap: _toggleItalic,
            tooltip: 'Cursiva',
          ),
          SizedBox(width: 2.w),
          _buildToolbarButton(
            icon: 'link',
            isActive: false,
            onTap: _insertLink,
            tooltip: 'Insertar enlace',
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              _focusNode.unfocus();
            },
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_up',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _LinkDialog extends StatefulWidget {
  final Function(String) onLinkInserted;

  const _LinkDialog({required this.onLinkInserted});

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Insertar enlace',
        style: AppTheme.lightTheme.textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Texto del enlace',
              hintText: 'Ej: Más información',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'URL',
              hintText: 'https://ejemplo.com',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _textController.text.trim();
            final url = _urlController.text.trim();
            if (text.isNotEmpty && url.isNotEmpty) {
              widget.onLinkInserted('[$text]($url)');
              Navigator.of(context).pop();
            }
          },
          child: Text('Insertar'),
        ),
      ],
    );
  }
}
