import React from 'react';

/**
 * Whether a `Stack.Host` rendered here asks a `Split.Column` or a
 * `Split.Inspector` to integrate with it.
 *
 * `Split.Column` and `Split.Inspector` provide `true`, unless they have
 * `disableStackIntegration`.
 * Components that render their children in a native container of their own
 * reset it to `false`: `Stack.Screen`, `Tabs.Host`, the sheets and
 * contained modals.
 */
const SplitColumnMarkerContext = React.createContext<boolean>(false);

export default SplitColumnMarkerContext;
