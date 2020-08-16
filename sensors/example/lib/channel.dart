
import 'package:sensors_example/aqueductLibrary.dart';
/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class MyProjectNameChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router
      .route("/example")
      .linkFunction((request) async {
        return Response.ok({"key": "value"});
      });
//    router
//        .route('/heroes')
//        .link(() => HeroesController());
//
//    router
//        .route('/heroesByGet/[:id]')
//        .link(() => HeroesController());
    return router;
  }


}
class HeroesControllerByNonDb extends ResourceController {
  final _heroes = [
    {'id': 11, 'name': 'Mr. Nice'},
    {'id': 12, 'name': 'Narco'},
    {'id': 13, 'name': 'Bombasto'},
    {'id': 14, 'name': 'Celeritas'},
    {'id': 15, 'name': 'Magneta'},
  ];

  @Operation.get()
  Future<Response> getAllHeroes() async {
    return Response.ok(_heroes);
  }
//  @Operation.get('id')
//  Future<Response> getHeroByID() async {
//    final id = int.parse(request.path.variables['id']);
//    final hero = _heroes.firstWhere((hero) => hero['id'] == id, orElse: () => null);
//    if (hero == null) {
//      return Response.notFound();
//    }
//
//    return Response.ok(hero);
//  }

  @Operation.get('id')
  Future<Response> getHeroByID(@Bind.path('id') int id) async {
    final hero = _heroes.firstWhere((hero) => hero['id'] == id, orElse: () => null);

    if (hero == null) {
      return Response.ok({'크크루삥뽕Z':'크크루삥'});
    }

    return Response.ok(hero);
  }
}

class HeroConfig extends Configuration {
  HeroConfig(String path): super.fromFile(File(path));

  DatabaseConfiguration database;
}

class HeroesChannel extends ApplicationChannel {
  ManagedContext context;

  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        "heroes_user", "password", "localhost", 5432, "heroes");

    context = ManagedContext(dataModel, persistentStore);
  }

  @override
  Controller get entryPoint {
    return Router()
      ..route("/BoardController/[:id]")
         // .link(() => BoardController(context));
//    ..route("/organizations/:orgName/heroes/[:heroID]")
//        .link(() => OrgHeroesController());
//    ..route("/organizations/:orgName/buildings/[:buildingID]")
//        .link(() => OrgBuildingController());
  }

}

