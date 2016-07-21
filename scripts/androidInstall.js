#!/usr/bin/env node

module.exports = function (context) {
    var path        = context.requireCordovaModule('path'),
        fs          = context.requireCordovaModule('fs'),
        shell       = context.requireCordovaModule('shelljs'),
        projectRoot = context.opts.projectRoot;

    var ConfigParser = null;
    try {
        ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    } catch(e) {
        ConfigParser = context.requireCordovaModule('cordova-lib/src/configparser/ConfigParser');
    }

    var config      = new ConfigParser(path.join(context.opts.projectRoot, "config.xml")),
        packageName = config.android_packageName() || config.packageName();

    console.info("Running afterPluginInstall.Hook: " + context.hook + ", Package: " + packageName + ", Path: " + projectRoot + ".");

    if (!packageName) {
        console.error("Package name could not be found!");
        return;
    }

    if (context.opts.cordova.platforms.indexOf("android") < 0) {
        console.info("Android platform has not been added.");
        return;
    }

    var pluginSrcPath = path.join(context.opts.plugin.dir, "src/android/LiveStreamingActivity.java");
    var platformSrcPath = path.join(projectRoot, "platforms", "android", "src/xwang/cordova/vcloud/livestreaming/LiveStreamingActivity.java");
    var targets = [pluginSrcPath, platformSrcPath];

    targets.forEach(function (f) {
        fs.readFile(f, {encoding: 'utf-8'}, function (err, data) {
            if (err) {
                throw err;
            }

            data = data.replace(/__PACKAGE_NAME__/g, packageName);
            fs.writeFileSync(f, data, "utf-8");
        });
    });
};
