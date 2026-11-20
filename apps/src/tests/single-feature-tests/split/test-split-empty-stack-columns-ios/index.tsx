import React from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import { Split, SplitHostCommands, Stack } from 'react-native-screens';
import { createScenario } from '@apps/tests/shared/helpers';
import { scenarioDescription } from './scenario-description';

type ScreenState = {
  key: string;
  activityMode: 'attached' | 'detached';
  animatesPush: boolean;
};

const INSPECTOR_PANES = ['files', 'terminal'] as const;
type InspectorPane = (typeof INSPECTOR_PANES)[number];

/**
 * Every column is navigated by a `Stack.Host`. The detail column and the inspector start with no attached screen, and
 * can be emptied again.
 */
function TestSplitEmptyStackColumns() {
  const hostRef = React.useRef<SplitHostCommands>(null);
  const nextId = React.useRef(1);
  const [details, setDetails] = React.useState<ScreenState[]>([]);
  const [inspectorPane, setInspectorPane] =
    React.useState<InspectorPane | null>(null);
  const [showInspector, setShowInspector] = React.useState(false);
  const [portraitOverlay, setPortraitOverlay] = React.useState(false);
  const [dismissals, setDismissals] = React.useState(0);
  const [nativeDismissals, setNativeDismissals] = React.useState(0);

  const selectDetail = (animatesPush: boolean) => {
    const key = `detail-${nextId.current++}`;
    setDetails(state => [
      ...state,
      { key, activityMode: 'attached', animatesPush },
    ]);
  };

  const clearDetails = () => {
    hostRef.current?.show('primary');
    setDetails(state =>
      state.map(screen => ({ ...screen, activityMode: 'detached' })),
    );
  };

  const removeDetail = (key: string) =>
    setDetails(state => state.filter(item => item.key !== key));

  return (
    <View style={styles.container}>
      <View style={styles.controls}>
        <Text testID="empty-column-state">
          Details: {details.length}; dismissals: {dismissals}
        </Text>
        <Text testID="empty-column-native-dismissals">
          Native dismissals: {nativeDismissals}
        </Text>
        <View style={styles.row}>
          <Button title="Select detail" onPress={() => selectDetail(true)} />
          <Button
            title="Select detail in place"
            onPress={() => selectDetail(false)}
          />
          <Button
            title="Show detail"
            onPress={() => hostRef.current?.show('secondary')}
          />
          <Button
            title="Show list"
            onPress={() => hostRef.current?.show('primary')}
          />
        </View>
        <View style={styles.row}>
          <Button title="Clear details" onPress={clearDetails} />
          <Button
            title="Unmount details"
            onPress={() => {
              hostRef.current?.show('primary');
              setDetails([]);
            }}
          />
        </View>
        <View style={styles.row}>
          <Button
            title={inspectorPane ? 'Clear inspector' : 'Populate inspector'}
            onPress={() => setInspectorPane(pane => (pane ? null : 'files'))}
          />
          <Button
            title="Switch inspector pane"
            onPress={() =>
              setInspectorPane(pane =>
                pane === 'files' ? 'terminal' : 'files',
              )
            }
          />
          <Button
            title="Toggle inspector"
            onPress={() => setShowInspector(value => !value)}
          />
          <Button
            title={portraitOverlay ? 'Tile in portrait' : 'Overlay in portrait'}
            onPress={() => setPortraitOverlay(value => !value)}
          />
        </View>
      </View>
      <Split.Host
        ref={hostRef}
        preferredDisplayMode="oneBesideSecondary"
        preferredSplitBehavior="tile"
        portraitPreferredDisplayMode={
          portraitOverlay ? 'secondaryOnly' : undefined
        }
        portraitPreferredSplitBehavior={portraitOverlay ? 'overlay' : undefined}
        topColumnForCollapsing="primary"
        showInspector={showInspector}
        onInspectorHide={() => setShowInspector(false)}>
        <Split.Column>
          <Stack.Host>
            <Stack.Screen screenKey="list" activityMode="attached">
              <Stack.HeaderConfig title="List" />
              <View style={[styles.content, styles.list]}>
                <Text testID="empty-column-list">List</Text>
                <Text>Select a detail, then show its column.</Text>
              </View>
            </Stack.Screen>
          </Stack.Host>
        </Split.Column>
        <Split.Column>
          <Stack.Host>
            {details.map(screen => (
              <Stack.Screen
                key={screen.key}
                screenKey={screen.key}
                activityMode={screen.activityMode}
                animatesPush={screen.animatesPush}
                onDismiss={key => {
                  removeDetail(key);
                  setDismissals(value => value + 1);
                }}
                onNativeDismiss={key => {
                  removeDetail(key);
                  setNativeDismissals(value => value + 1);
                }}>
                <Stack.HeaderConfig title={screen.key} />
                <View style={[styles.content, styles.detail]}>
                  <Text testID={`empty-column-${screen.key}`}>
                    {screen.key}
                  </Text>
                </View>
              </Stack.Screen>
            ))}
          </Stack.Host>
        </Split.Column>
        <Split.Inspector>
          <Stack.Host>
            {INSPECTOR_PANES.map(pane => (
              <Stack.Screen
                key={pane}
                screenKey={`inspector-${pane}`}
                activityMode={inspectorPane === pane ? 'attached' : 'detached'}>
                <Stack.HeaderConfig title={`Inspector ${pane}`} />
                <View style={[styles.content, styles.inspector]}>
                  <Text testID={`empty-column-inspector-${pane}`}>
                    Inspector {pane}
                  </Text>
                  <Button
                    title="Close inspector"
                    onPress={() => setShowInspector(false)}
                  />
                </View>
              </Stack.Screen>
            ))}
          </Stack.Host>
        </Split.Inspector>
      </Split.Host>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  controls: { paddingTop: 60, paddingBottom: 8, backgroundColor: 'white' },
  row: { flexDirection: 'row', flexWrap: 'wrap' },
  content: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  list: { backgroundColor: '#dbeafe' },
  detail: { backgroundColor: '#dcfce7' },
  inspector: { backgroundColor: '#fef3c7' },
});

export default createScenario(TestSplitEmptyStackColumns, scenarioDescription);
