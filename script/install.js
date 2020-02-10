// 安装插件时会node运行此文件
const fs = require('fs');
const path = require('path');

let androidPath = path.resolve(process.cwd(), 'platforms/android/eeuiApp');
let gradPath = path.resolve(androidPath, 'build.gradle');
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

let to = path.resolve(androidPath, 'app/src/main/res/drawable');
_mkdirsSync(to);

function _mkdirsSync(dirname)  {
    if (fs.existsSync(dirname)) {
        return true;
    } else {
        if (_mkdirsSync(path.dirname(dirname))) {
            fs.mkdirSync(dirname);
            return true;
        }
    }
}

function _copyFile() {
    ['xhdpi', 'xxhdpi', 'xxxhdpi', 'hdpi', 'mdpi'].some((dName) => {
        let dPath = path.resolve(androidPath, 'app/src/main/res/mipmap-' + dName + '/ic_launcher.png');
        if (fs.existsSync(dPath)) {
            fs.copyFileSync(dPath, path.resolve(to, 'umeng_push_notification_default_large_icon.png'));
            fs.copyFileSync(dPath, path.resolve(to, 'umeng_push_notification_default_small_icon.png'));
            return true;
        }
    });
}

_copyFile();
