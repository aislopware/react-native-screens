package com.swmansion.rnscreens.react.common

import com.facebook.react.bridge.WritableMap
import com.facebook.react.common.annotations.UnstableReactNativeAPI
import com.facebook.react.uimanager.StateWrapper

@OptIn(UnstableReactNativeAPI::class)
internal fun StateWrapper.updateStateCompat(
    map: WritableMap,
    immediate: Boolean,
) {
    updateState(map, if (immediate) StateWrapper.UpdateMode.unstable_Immediate else StateWrapper.UpdateMode.Asynchronous)
}
