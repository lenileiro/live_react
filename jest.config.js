module.exports = {
  testEnvironment: "jsdom",
  setupFilesAfterEnv: ["@testing-library/jest-dom/extend-expect"],
  transform: {
    "^.+\\.(js|jsx)$": "babel-jest",
  },
  testEnvironmentOptions: {
    url: "http://localhost",
  },
};
