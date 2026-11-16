const NOOP = () => {
  console.warn(
    '[RNScreens] Split component is supported only for iOS. Consider using an alternative layout for Web.',
  );
  return null;
};

const Column = NOOP;
const Stack = NOOP;
const Screen = NOOP;
const Inspector = NOOP;

// TODO: refactor to drop `Screen` suffix as the API name is really long at the moment
const SplitScreen = {
  Column,
  Stack,
  Screen,
  Inspector,
};

export default SplitScreen;
