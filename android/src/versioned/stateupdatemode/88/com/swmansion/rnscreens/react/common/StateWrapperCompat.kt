package com.swmansion.rnscreens.react.common

import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.StateWrapper

internal fun StateWrapper.updateStateCompat(
    map: WritableMap,
    immediate: Boolean,
) {
    // RN < 0.89 has no StateWrapper.UpdateMode, so an immediate update degrades to the plain asynchronous one.
    updateState(map)
}
