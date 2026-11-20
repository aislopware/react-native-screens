import React from 'react';
import { StyleSheet } from 'react-native';
import warnOnce from 'warn-once';
import SplitScreenNativeComponent from '../../fabric/split/SplitScreenNativeComponent';
import SplitColumnMarkerContext from './SplitColumnMarkerContext';
import type {
  SplitColumnProps,
  SplitInspectorProps,
} from './SplitScreen.types';

/**
 * Whether the integration with a stack is on. It is configured once, when the
 * column or the inspector is mounted. `Stack.Host` and `Stack.Screen` read it
 * from the context.
 */
function useStackIntegration(
  componentName: string,
  disableStackIntegration: boolean,
) {
  const [isStackIntegrationDisabled] = React.useState(disableStackIntegration);

  React.useEffect(() => {
    warnOnce(
      disableStackIntegration !== isStackIntegrationDisabled,
      `[RNScreens] \`disableStackIntegration\` of ${componentName} cannot be changed after it is mounted. The change is ignored.`,
    );
  }, [componentName, disableStackIntegration, isStackIntegrationDisabled]);

  return !isStackIntegrationDisabled;
}

function Column(props: SplitColumnProps) {
  const { children, disableStackIntegration = false, ...restProps } = props;
  const isStackIntegrationEnabled = useStackIntegration(
    'Split.Column',
    disableStackIntegration,
  );

  return (
    <SplitScreenNativeComponent
      columnType="column"
      {...restProps}
      style={StyleSheet.absoluteFill}>
      <SplitColumnMarkerContext.Provider value={isStackIntegrationEnabled}>
        {children}
      </SplitColumnMarkerContext.Provider>
    </SplitScreenNativeComponent>
  );
}

function Inspector(props: SplitInspectorProps) {
  const { children, disableStackIntegration = false, ...restProps } = props;
  const isStackIntegrationEnabled = useStackIntegration(
    'Split.Inspector',
    disableStackIntegration,
  );

  return (
    <SplitScreenNativeComponent
      columnType="inspector"
      {...restProps}
      style={StyleSheet.absoluteFill}>
      <SplitColumnMarkerContext.Provider value={isStackIntegrationEnabled}>
        {children}
      </SplitColumnMarkerContext.Provider>
    </SplitScreenNativeComponent>
  );
}

// TODO: refactor to drop `Screen` suffix as the API name is really long at the moment
const SplitScreen = {
  Column,
  Inspector,
};

export default SplitScreen;
