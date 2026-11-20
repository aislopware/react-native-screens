module.exports = {
  preset: '@react-native/jest-preset',
  // The example apps and the react-navigation submodule have their own
  // dependencies and test setups.
  modulePathIgnorePatterns: [
    'FabricExample',
    'TVOSExample',
    '<rootDir>/react-navigation/',
  ],
};
