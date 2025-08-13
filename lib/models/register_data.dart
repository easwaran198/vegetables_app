class RegisterData{
  final String name;
  final String mobileno;
  final String emailaddress;
  final String address;

  RegisterData({required this.name,required this.mobileno,required this.emailaddress,required this.address});

  Map<String,dynamic> toJson(){
    return {
      'name' : name,
      'mobileno' : mobileno,
      'emailaddress' : emailaddress,
      'address' : address,
    };
  }
}