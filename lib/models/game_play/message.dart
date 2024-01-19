
import 'package:flutter/material.dart';

abstract class Message{
  Widget get builder;
}

class HostingMessage extends Message{
  HostingMessage();
  
  @override
  Widget get builder => Container();
}