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
//推送模块
const umengPush = app.requireModule("eeui/umengPush");
//统计模块
const umengAnalytics = app.requireModule("eeui/umengAnalytics");
```

## 参数配置

[eeui.config.js](https://eeui.app/guide/config.html) 配置如下：

```js
module.exports = {
    //......
    umeng: {
        ios: {
            enabled: true,
            appKey: "",
            channel: "",
        },
        android: {
            enabled: true,
            appKey: "",
            messageSecret: "",
            channel: "",

            xiaomiAppId: "",
            xiaomiAppKey: "",
            huaweiAppId: "",
            meizuAppId: "",
            meizuAppKey: "",
            oppoAppKey: "",
            oppoAppSecret: "",
            vivoAppId: "",
            vivoAppKey: "",
        }
    },
    //......
}
```

## 调用方法 

* 推送模块

```js
/**
 * 获取deviceToken
 * @return 返回token字符串
 */
umengPush.deviceToken();

/**
 * 设置通知栏显示数量（限制Android）
 * @param num
 */
umengPush.setDisplayNotificationNumber(int num);

/**
 * 自定义通知栏是否显示（限制Android）
 * @param show
 */
umengPush.setNotificaitonOnForeground(boolean show);

/**
 * 关闭推送（限制Android）
 * @param callback
 */
umengPush.disable(JSCallback callback);

/**
 * 打开推送（限制Android）
 * @param callback
 */
umengPush.enable(JSCallback callback);

/**
 * 设置标签
 * @param tag
 * @param callback
 */
umengPush.addTag(String tag, JSCallback callback);

/**
 * 删除标签
 * @param tag
 * @param callback
 */
umengPush.deleteTag(String tag, JSCallback callback);

/**
 * 获取服务器端的所有标签
 * @param callback
 */
umengPush.listTag(JSCallback callback);

/**
 * 添加别名
 * @param alias
 * @param aliasType
 * @param callback
 */
umengPush.addAlias(String alias, String aliasType, JSCallback callback);

/**
 * 删除别名
 * @param alias
 * @param aliasType
 * @param callback
 */
umengPush.deleteAlias(String alias, String aliasType, JSCallback callback);
```

* 统计模块

```js
/**
 * 页面开始（默认已加载）
 * @param pageName
 */
umengAnalytics.onPageStart(String pageName)

/**
 * 页面结束（默认已加载）
 * @param pageName
 */
umengAnalytics.onPageEnd(String pageName)

/**
 * 计算事件
 * @param eventId
 */
umengAnalytics.onEvent(String eventId)

/**
 * 计算事件
 * @param eventId
 * @param eventLabel
 */
umengAnalytics.onEventWithLable(String eventId, String eventLabel)

/**
 * 计算事件
 * @param eventId
 * @param map
 */
umengAnalytics.onEventWithMap(String eventId, JSONObject map)

/**
 * 计算事件
 * @param eventID
 * @param property
 */
umengAnalytics.onEventObject(String eventID, JSONObject property)

/**
 * 计算事件
 * @param eventId
 * @param map
 * @param value
 */
umengAnalytics.onEventWithMapAndCount(String eventId,JSONObject map,int value)

/**
 * 注册预置事件属性
 * @param map
 */
umengAnalytics.registerPreProperties(JSONObject map)

/**
 * 删除指定预置事件属性
 * @param propertyName
 */
umengAnalytics.unregisterPreProperty(String propertyName)

/**
 * 获取全部预置事件属性
 * @param callback
 */
umengAnalytics.getPreProperties(JSCallback callback)

/**
 * 清空全部预置事件属性
 */
umengAnalytics.clearPreProperties()

/**
 * 设置关注首次触发track事件接口
 * @param array
 */
umengAnalytics.setFirstLaunchEvent(JSONArray array)

/**
 * 当用户使用自有账号登录时
 * @param puid
 */
umengAnalytics.profileSignInWithPUID(String puid)

/**
 * 当用户使用第三方账号（如新浪微博）登录时
 * @param provider
 * @param puid
 */
umengAnalytics.profileSignInWithPUIDWithProvider(String provider, String puid)

/**
 * 登出
 */
umengAnalytics.profileSignOff()
```

## 推送消息


```html
<template>
    ...
</template>

<script>
    export default {
        pageMessage: function (data) {
            let msg = data.message;
            if (msg.messageType == 'umengToken') {
                console.log('获取到友盟token：', msg.token);  //推荐使用调用方法【umengPush.deviceToken()】获取token
            } else if (msg.messageType == 'notificationClick') {
                console.log('点击了通知栏消息：', msg);
            }
        }
    }
</script>
```