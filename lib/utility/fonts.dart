import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle getFonts (double fontsize,Color color){
  return GoogleFonts.poppins(fontWeight: FontWeight.w600,fontSize: fontsize ,color:color );
}
TextStyle searchFonts (double fontsize,Color color){
  return GoogleFonts.poppins(fontWeight: FontWeight.w400,fontSize: fontsize ,color:color );
}
TextStyle formFonts (double fontsize,Color color){
  return GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: fontsize ,color:color );
}
TextStyle appbarFonts (double fontsize,Color color){
  return GoogleFonts.poppins(fontWeight: FontWeight.w700,fontSize: fontsize ,color:color );
}
TextStyle DrewerFonts (){
  return GoogleFonts.nunitoSans(fontWeight: FontWeight.w700,fontSize: 14 ,color:Colors.black );
}
TextStyle filedFonts (){
  return GoogleFonts.poppins(fontWeight: FontWeight.w400,fontSize: 14 ,color:Colors.black );
}
TextStyle splashFonts (){
  return GoogleFonts.hahmlet(fontWeight: FontWeight.w700,fontSize: 44 ,color:Colors.white );
}
TextStyle splash2Fonts (){
  return GoogleFonts.poppins(fontWeight: FontWeight.w400,fontSize: 14 ,color:Colors.white );
}
TextStyle drewerFonts (){
  return GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: 14 ,color:Color(0xFF8A8C91)
 );
}