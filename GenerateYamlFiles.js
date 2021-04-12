const
    fs = require('fs-extra'),
    path = require('path'),
    glob = require('glob'),
    os = require('os'),
    BASE_PATH = './',

    // This is the secret template
    TEMPLATE = `
kind: Secret
apiVersion: v1
metadata:
    name: __ServiceName__-secret
    namespace: __ServiceName__
type: Opaque
data:`;

// options is optional
glob("**/.env/**/.env", {
    cwd: BASE_PATH,
    nodir: true
}, function (er, files) {
    files.forEach((file) => {
        console.log(file);
        // Load the configuration file and convert it to JSON
        let config = require('dotenv').config({ path: BASE_PATH + file }),
            baseDir = path.dirname(file),
            secretFile = TEMPLATE;

        // Process the keys of each .env file
        Object.keys(config.parsed)
            .forEach((key) => {
                secretFile += `${os.EOL}  ${key.trim()}: "${new Buffer(config.parsed[key]).toString('base64')}"`
            });

        // Write the secret file
        fs.writeFile(`${BASE_PATH}/${baseDir}/env.yaml`, secretFile);

    });
})
