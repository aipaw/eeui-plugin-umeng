# 友盟推送模块

## 安装

```shell script
eeui plugin install https://github.com/aipaw/eeui-plugin-umeng
```

## 卸载

```shell script
eeui plugin uninstall https://github.com/aipaw/eeui-plugin-umeng
```

## 引用

```js
const umeng = app.requireModule("eeui/umeng");
```

## 参数配置

[eeui.config.js](https://eeui.app/guide/config.html) 配置如下：
```js
module.exports = {
    //......
    "umeng": {
        "ios": {
            "enabled": true,
            "appKey": "5f1ab6bad62dd10bc71bed5a",
            "channel": "wook"
        },
        "android": {
            "enabled": true,
            "appKey": "5f1ab3ec6cab60339c37c67b",
            "messageSecret": "274ef1c5897d4db4ea963820a5635622",
            "channel": "wook"
        }
    },
    //......
}
```

## 调用方法 

```
/**
* 获取token
* @返回 {"status":"success", "msg":"", "token":"友盟token"}
 */
let variable = umeng.getToken()

```

## 推送消息

* 支持2.3.9+

```html
<template>
    ...
</template>

<script>
    export default {
        pageMessage: function (data) {
            let msg = data.message;
            if (msg.messageType == 'umengToken') {
                console.log('获取到友盟token：', msg.token);  //建议使用调用方法获取
            } else if (msg.messageType == 'notificationClick') {
                console.log('点击了通知栏消息：', msg);
            }
        }
    }
</script>
```

## 点击通知事件

* **支持：2.3.9版本之前**

> `umeng.setNotificationClickHandler` 自定义通知打开动作（点击通知事件）

```
/**
 * @param callback  回调事件
 */
umeng.setNotificationClickHandler(callback(result))

```

#### callback 回调`result`说明

```
{
    "status":"click",                   //为 “click” 时就是点击通知的动作了
    "msgid":"uuze1vb155496745348510",   //消息ID
    "title":"测试标题",                  //消息标题
    "subtitle":"12345678",              //消息副标题
    "text":"测试内容",                   //消息内容
    "extra":{                           //额外参数

    },
    "rawData":{                         //消息原始数据

    }
}

```

#### 简单示例

```
umeng.setNotificationClickHandler(function(result) {
    //......
});
```