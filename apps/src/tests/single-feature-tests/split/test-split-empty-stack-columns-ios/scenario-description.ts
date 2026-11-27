import type { ScenarioDescription } from '@apps/tests/shared/helpers';

export const scenarioDescription: ScenarioDescription = {
  name: 'Empty stack columns',
  key: 'test-split-empty-stack-columns-ios',
  platforms: ['ios'],
  devices: ['iphone', 'ipad'],
  e2eCoverage: 'incomplete',
  smokeTest: false,
};
