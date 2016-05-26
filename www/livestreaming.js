var exec = require('cordova/exec');

module.exports = {
  play: function (url, title, options, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "LiveStreaming", "play", [url, title, options]);
  }
};