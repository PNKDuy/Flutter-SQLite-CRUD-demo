import 'package:flutter/material.dart';
import 'package:sqlite_crud/utils/database_helper.dart';
import './models/contact.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Contact _contact = Contact();
  List<Contact> _contacts = [];
  DatabaseHelper _dbHelper;
  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  void initState(){
    super.initState();
    setState((){
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshContactList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ), 
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _form(), _list(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _form() => Container(
    padding: EdgeInsets.symmetric(vertical:15, horizontal:30),
    child: Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _ctrlName,
            decoration: InputDecoration(labelText:'Fullname'),
            onSaved: (value) => setState(() => _contact.name = value),
            validator: (value) => (value.length==0 ? 'This filed is required' :null),
          ),
          TextFormField(
            controller: _ctrlMobile,
            decoration: InputDecoration(labelText:'Mobile'),
            onSaved: (value) => setState(() => _contact.mobile = value),
            validator: (value) => (value.length < 10 ? 'Atleast 10 characters required' :null),
          ),
          Container(
            margin:EdgeInsets.all(10.0),
            child: RaisedButton(
            onPressed: () => _onSubmit(),
            child: Text('Submit'),
            color: Colors.grey
          )
          )
        ]
      )
    )
  );

  _refreshContactList() async {
    List<Contact> x = await _dbHelper.fetchContacts();
    setState((){
      _contacts = x;
    });
  }

  _onSubmit() async {
    var form = _formKey.currentState;

    if(form.validate()){
      form.save();
      if(_contact.id == null) await _dbHelper.insertContact(_contact);
      else await _dbHelper.updateContact(_contact);
      _refreshContactList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = null;
    });
  }

  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index){
          return Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.account_circle,
                size: 40.0),
                title: Text(_contacts[index].name.toUpperCase()),
                subtitle: Text(_contacts[index].mobile),
                trailing: IconButton(icon: Icon(Icons.delete_sweep),
                onPressed: ()async{
                  await _dbHelper.deleteContact(_contacts[index].id);
                  _resetForm();
                  _refreshContactList();
                },),
                onTap: (){
                  setState(() {
                    _contact = _contacts[index];
                    _ctrlName.text = _contacts[index].name;
                    _ctrlMobile.text = _contacts[index].mobile;
                  });
                },
              ),
              Divider(height: 5.0)
            ]
          );
        },
        itemCount: _contacts.length,
      ),
    
    ),
  );
}
