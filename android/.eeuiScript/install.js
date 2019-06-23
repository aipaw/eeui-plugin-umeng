const fs = require('fs');
const file = require('./file');

let workPath = process.cwd();
let androidPath = workPath + '/platforms/android/eeuiApp';
let gradPath = androidPath + '/build.gradle';
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

let to = androidPath + '/app/src/main/res/drawable';
file.mkdirsSync(to);

function _copyFile() {
    ['xhdpi', 'xxhdpi', 'xxxhdpi', 'hdpi', 'mdpi'].some((dName) => {
        let dPath = androidPath + '/app/src/main/res/mipmap-' + dName + '/ic_launcher.png';
        if (fs.existsSync(dPath)) {
            fs.copyFileSync(dPath, to + '/umeng_push_notification_default_large_icon.png');
            fs.copyFileSync(dPath, to + '/umeng_push_notification_default_small_icon.png');
            return true;
        }
    });
}

_copyFile();
