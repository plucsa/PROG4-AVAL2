import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../provider/to_do_list_provider.dart';

class ItemPage extends StatefulWidget {
  final Item? item;

  const ItemPage({
    super.key,
    this.item,
  });

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    final item = widget.item;

    super.initState();

    _titleController.text = item?.title ?? '';
    _descriptionController.text = item?.description ?? '';
    _dateController.text = item?.date ?? '';
    _categoryController.text = item?.category ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date to display
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2100), // Maximum date
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.toLocal()}".split(' ')[0]; // Format the date
      });
    }
  }

  void _formSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Item(
      id: widget.item?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _dateController.text.trim(),
      category: _categoryController.text.trim(),
    );

    final provider = Provider.of<ToDoListProvider>(
      context,
      listen: false,
    );
    final nav = Navigator.of(context);

    setState(() => _isLoading = true);
    try {
      await provider.save(item);
      nav.pop();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _titleValidator(String? text) {
    if ((text == null) || text.isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  String? _descriptionValidator(String? text) {
    final error = _titleValidator(text);
    if (error != null) {
      return error;
    }
    if ((text == null) || text.isEmpty) {
      return 'Este campo é obrigatório';
    }

    return null;
  }

  String? _dateValidator(String? text) {
    if ((text == null) || text.isEmpty) {
      return 'Este campo é obrigatório';
    }
    try {
      DateTime.parse(text);
    } catch (e) {
      return 'Data inválida';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        Provider.of<ToDoListProvider>(context, listen: true).categoryItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Item'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formSubmit(context),
        child: const Icon(Icons.save),
      ),
      body: !_isLoading
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Título',
                          ),
                          controller: _titleController,
                          validator: _titleValidator,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                          ),
                          controller: _descriptionController,
                          validator: _descriptionValidator,
                        ),
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Data',
                          ),
                          validator: _dateValidator,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                              labelText: 'Escolha uma Categoria'),
                          value: categories.first,
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _categoryController.text = value ?? '';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
