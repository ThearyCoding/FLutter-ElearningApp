import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GrabBikeForm extends StatefulWidget {
  @override
  _GrabBikeFormState createState() => _GrabBikeFormState();
}

class _GrabBikeFormState extends State<GrabBikeForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _workController = TextEditingController();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GrabBike Application'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, size: 50, color: Colors.white),
                        onPressed: () {
                          // Handle take selfie action
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Take Selfie'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  label: RichText(
                    text: const TextSpan(
                      text: 'Disability status | ',
                      style: TextStyle( fontSize: 16.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your disability status';
                  }
                  return null;
                },
                onSaved: (value) {
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  label: RichText(
                    text: const TextSpan(
                      text: 'Gender | ',
                      style: TextStyle( fontSize: 16.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your gender';
                  }
                  return null;
                },
                onSaved: (value) {
                },
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Date Of Birth | ',
                        style: TextStyle( fontSize: 16.0),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  baseStyle: TextStyle(fontSize: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _selectedDate == null
                            ? 'Select your birth date'
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _workController,
                decoration: InputDecoration(
                  labelText:
                      'Besides driving, do you work anywhere else? | បន្ទាបពីការបើកបរ តើអ្នកមានធ្វើការផ្សេងបន្ថែមទៀតដែរឬទេ?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Process the data
                  }
                },
                child: Text('Save'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Navigate to next page
                  }
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}