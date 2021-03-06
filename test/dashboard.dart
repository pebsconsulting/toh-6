@TestOn('browser')

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_test/angular_test.dart';
import 'package:angular_tour_of_heroes/in_memory_data_service.dart';
import 'package:angular_tour_of_heroes/src/routes.dart';
import 'package:angular_tour_of_heroes/src/dashboard_component.dart';
import 'package:angular_tour_of_heroes/src/dashboard_component.template.dart'
    as ng;
import 'package:angular_tour_of_heroes/src/hero_service.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'dashboard.template.dart' as self;
import 'dashboard_po.dart';
import 'matchers.dart';
import 'utils.dart';

NgTestFixture<DashboardComponent> fixture;
DashboardPO po;

@GenerateInjector([
  const ValueProvider.forToken(appBaseHref, '/'),
  const ClassProvider(Client, useClass: InMemoryDataService),
  const ClassProvider(Routes),
  const ClassProvider(HeroService),
  routerProviders,
  const ClassProvider(Router, useClass: MockRouter),
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  final injector = new InjectorProbe(rootInjector);
  final testBed = NgTestBed.forComponent<DashboardComponent>(
      ng.DashboardComponentNgFactory,
      rootInjector: injector.factory);

  setUp(() async {
    fixture = await testBed.create();
    po = await new DashboardPO().resolve(fixture);
  });

  tearDown(disposeAnyRunningTest);

  test('title', () async {
    expect(await po.title, 'Top Heroes');
  });

  test('show top heroes', () async {
    final expectedNames = ['Narco', 'Bombasto', 'Celeritas', 'Magneta'];
    expect(await po.heroNames, expectedNames);
  });

  test('select hero and navigate to detail', () async {
    final mockRouter = injector.get<MockRouter>(Router);
    clearInteractions(mockRouter);
    await po.selectHero(3);
    final c = verify(mockRouter.navigate(typed(captureAny), typed(captureAny)));
    expect(c.captured[0], '/heroes/15');
    expect(c.captured[1], isNavParams()); // empty params
    expect(c.captured.length, 2);
  });

  test('no search no heroes', () async {
    expect(await po.heroesFound, []);
  });

  group('Search hero:', heroSearchTests);
}

void heroSearchTests() {
  final matchedHeroNames = [
    'Magneta',
    'RubberMan',
    'Dynama',
    'Magma',
  ];

  setUp(() async {
    await po.search.type('ma');
    // await new Future.delayed(const Duration(seconds: 1)); // still needed?
    po = await new DashboardPO().resolve(fixture);
  });

  test('list matching heroes', () async {
    expect(await po.heroesFound, matchedHeroNames);
  });
}
