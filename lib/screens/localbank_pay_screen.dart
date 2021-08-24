import 'package:ebook/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class LocalBankPayScreen extends StatefulWidget {
  final double amount;
  final String note;
  final String txtID;
  final String bankName;
  const LocalBankPayScreen({
    Key key,
    this.amount,
    this.note,
    this.txtID,
    this.bankName,
  }) : super(key: key);

  @override
  _LocalBankPayScreenState createState() => _LocalBankPayScreenState();
}

class _LocalBankPayScreenState extends State<LocalBankPayScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amount;
  String _note;
  String _txtID;
  String _bankName;

  @override
  void initState() {
    _amount = widget.amount ?? 0;
    _note = widget.note ?? "";
    _txtID = widget.txtID ?? "";
    _bankName = widget.bankName ?? "ABA";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(keyString(context, "error_select_payment_option")),
                trailing: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                    backgroundImage: AssetImage("assets/icons/aba_bank.jpg")),
                selected: _bankName == "ABA",
                title: Text("ABA ACCOUNT"),
                subtitle: Text("MEY SAMETH (000443344)"),
                onTap: () => onSelected("ABA"),
                trailing: Checkbox(
                  value: _bankName == "ABA",
                  onChanged: (v) {
                    setState(() {
                      _bankName = "ABA";
                    });
                  },
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/icons/acelida_bank.jpg")),
                selected: _bankName == "ACLEDA",
                title: Text("ACLEDA"),
                subtitle: Text("MEY SAMETH (070885656)"),
                onTap: () => onSelected("ACLEDA"),
                trailing: Checkbox(
                  value: _bankName == "ACLEDA",
                  onChanged: (v) {
                    setState(() {
                      _bankName = "ACLEDA";
                    });
                  },
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundImage: AssetImage("assets/icons/wing_bank.jpg")),
                selected: _bankName == "WING",
                title: Text("WING"),
                subtitle: Text("MEY SAMETH (070885656)"),
                onTap: () => onSelected("WING"),
                trailing: Checkbox(
                  value: _bankName == "WING",
                  onChanged: (v) {
                    setState(() {
                      _bankName = "WING";
                    });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  onChanged: (v) {
                    setState(() {
                      _txtID = v;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: keyString(context, 'transaction id')),
                  validator: (String value) {
                    if (value.isEmpty && _amount > 0)
                      return errorThisFieldRequired;
                    return null;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  onChanged: (v) {
                    setState(() {
                      _note = v;
                    });
                  },
                  decoration:
                      InputDecoration(hintText: keyString(context, 'note')),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                child: ElevatedButton(
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        keyString(context, "lbl_confirmation"),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onPressed: _confirm,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  onSelected(value) {
    setState(() {
      _bankName = value;
    });
  }

  _confirm() {
    if (!_formKey.currentState.validate()) {
      return "";
    }
    Navigator.of(context).pop({
      "amount": _amount,
      "note": _note,
      "txtID": _txtID ?? "${DateTime.now().millisecondsSinceEpoch}",
      "bankName": _bankName,
    });
  }
}
