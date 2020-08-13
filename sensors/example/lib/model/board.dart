import 'package:sensors_example/aqueductLibrary.dart';

class Board extends ManagedObject implements _Board{
  @override
  int boardCount;

  @override
  int sn;

  @override
  String title;

}

class _Board {
  @primaryKey
  int sn;

  @Column(unique: false)
  String title;

  @Column(unique: false)
  int boardCount;
}

class BoardController extends ResourceController {

  BoardController(ManagedContext context);
}