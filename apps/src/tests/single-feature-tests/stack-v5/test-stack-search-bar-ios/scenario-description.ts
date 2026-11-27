import type { ScenarioDescription } from '@apps/tests/shared/helpers';

export const scenarioDescription: ScenarioDescription = {
  name: 'Search bar (iOS)',
  key: 'test-stack-search-bar-ios',
  details:
    'Search events, ref commands, header menus and search controller lifecycle',
  platforms: ['ios'],
  devices: ['iphone'],
  e2eCoverage: 'incomplete',
  smokeTest: false,
};
