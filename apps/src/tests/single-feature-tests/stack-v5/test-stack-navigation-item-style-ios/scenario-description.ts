import type { ScenarioDescription } from '@apps/tests/shared/helpers';

export const scenarioDescription: ScenarioDescription = {
  name: 'Stack Navigation Item Style (iOS)',
  key: 'test-stack-navigation-item-style-ios',
  details:
    'Compares navigator/browser/editor styles, live updates, removal/remounting, and screen isolation.',
  platforms: ['ios'],
  devices: ['iphone', 'ipad'],
  e2eCoverage: 'full',
  smokeTest: false,
};
