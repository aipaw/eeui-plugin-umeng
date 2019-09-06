const fs = require('fs');
const file = require('./file');
const dirCut = /^win/.test(process.platform) ? "\\" : "/";

let workPath = process.cwd();
let androidPath = workPath + dirCut + 'platforms' + dirCut + 'android' + dirCut + 'eeuiApp';
let gradPath = androidPath + dirCut + 'build.gradle';
let result = fs.readFileSync(gradPath, 'utf8');
let values = result.split('\n');

let packageName = "";
for (let i = 0; i < values.length; i++) {
    let item = values[i];
    if (item.indexOf('applicationId') !== -1) {
        packageName = (item.split('=')[1] + "").trim();
        packageName = packageName.replace(/\"/g, "");
        break
    }
}

let to = androidPath + dirCut + 'app' + dirCut + 'src' + dirCut + 'main' + dirCut + 'res' + dirCut + 'drawable';
file.mkdirsSync(to);

function _copyFile() {
    ['xhdpi', 'xxhdpi', 'xxxhdpi', 'hdpi', 'mdpi'].some((dName) => {
        let dPath = androidPath + dirCut + 'app' + dirCut + 'src' + dirCut + 'main' + dirCut + 'res' + dirCut + 'mipmap-' + dName + dirCut + 'ic_launcher.png';
        if (fs.existsSync(dPath)) {
            fs.copyFileSync(dPath, to + dirCut + 'umeng_push_notification_default_large_icon.png');
            fs.copyFileSync(dPath, to + dirCut + 'umeng_push_notification_default_small_icon.png');
            return true;
        }
    });
}

_copyFile();
