package app.eeui.umeng.ui.entry;

import android.app.Activity;
import android.app.Application.ActivityLifecycleCallbacks;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXException;
import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.PushAgent;
import com.umeng.message.UHandler;
import com.umeng.message.entity.UMessage;

import org.json.JSONException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import app.eeui.framework.BuildConfig;
import app.eeui.framework.extend.annotation.ModuleEntry;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiMap;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.ui.eeui;
import app.eeui.umeng.ui.module.eeuiUmengModule;

/**
 * Created by WDM on 2018/3/27.
 */
@ModuleEntry
public class eeui_umeng {

    private static boolean isRegister = false;

    /**
     * ModuleEntry
     * @param content
     */
    public void init(Context content) {
        JSONObject umeng = eeuiJson.parseObject(eeuiBase.config.getObject("umeng").get("android"));
        if (eeuiJson.getBoolean(umeng, "enabled")) {
            eeui_umeng.init(eeuiJson.getString(umeng, "appKey"), eeuiJson.getString(umeng, "messageSecret"), eeuiJson.getString(umeng, "channel"));
        }
        //注册模块
        if (!isRegister) {
            isRegister = true;
            try {
                WXSDKEngine.registerModule("umeng", eeuiUmengModule.class);
            } catch (WXException e) {
                e.printStackTrace();
            }
        }
    }

    /****************************************************************************************/
    /****************************************************************************************/
    /****************************************************************************************/

    private static final String TAG = "eeui_umeng";

    private static JSONObject umeng_token = new JSONObject();

    private static List<notificationClickHandlerBean> mNotificationClickHandler = new ArrayList<>();

    public static void init(String key, String secret) {
        init(key, secret, null);
    }

    public static void init(String key, String secret, String channel) {
        //初始化
        UMConfigure.init(eeui.getApplication(), key, channel, UMConfigure.DEVICE_TYPE_PHONE, secret);
        UMConfigure.setLogEnabled(BuildConfig.DEBUG);
        //注册统计
        eeui.getApplication().registerActivityLifecycleCallbacks(mCallbacks);
        //注册推送
        PushAgent mPushAgent = PushAgent.getInstance(eeui.getApplication());
        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String deviceToken) {
                umeng_token.put("status", "success");
                umeng_token.put("msg", "");
                umeng_token.put("token", deviceToken);
            }

            @Override
            public void onFailure(String s, String s1) {
                umeng_token.put("status", "error");
                umeng_token.put("msg", s);
                umeng_token.put("token", "");
            }
        });
        //打开通知动作
        mPushAgent.setNotificationClickHandler(new UHandler() {
            @Override
            public void handleMessage(Context context, UMessage uMessage) {
                try {
                    clickHandleMessage(uMessage);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                //
                LinkedList<Activity> mLinkedList = eeui.getActivityList();
                Activity mActivity = mLinkedList.getLast();
                if (mActivity != null) {
                    Intent intent = new Intent(context, mActivity.getClass());
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);
                }
            }
        });
    }

    public static void addNotificationClickHandler(Context context, JSCallback callback) {
        mNotificationClickHandler.add(new notificationClickHandlerBean(context, callback));
    }

    public static JSONObject getToken() {
        return umeng_token;
    }

    private static class notificationClickHandlerBean {
        Context context;
        JSCallback callback;

        notificationClickHandlerBean(Context context, JSCallback callback) {
            this.context = context;
            this.callback = callback;
        }
    }

    private static void clickHandleMessage(UMessage uMessage) throws JSONException {
        mNotificationClickHandler = eeuiCommon.removeNull(mNotificationClickHandler);
        if (mNotificationClickHandler.size() == 0) {
            return;
        }
        LinkedList<Activity> mLinkedList = eeui.getActivityList();
        for (int i = 0; i < mNotificationClickHandler.size(); i++) {
            notificationClickHandlerBean mBean = mNotificationClickHandler.get(i);
            if (mBean != null) {
                boolean isCallBack = false;
                for (int j = 0; j < mLinkedList.size(); j++) {
                    if (mLinkedList.get(j).equals(mBean.context)) {
                        Map<String, Object> temp = eeuiMap.jsonToMap(uMessage.getRaw());
                        Map<String, Object> body = eeuiMap.objectToMap(temp.get("body"));
                        Map<String, Object> extra = eeuiMap.objectToMap(temp.get("extra"));
                        if (body != null) {
                            Map<String, Object> data = new HashMap<>();
                            data.put("status", "click");
                            data.put("msgid", eeuiParse.parseStr(body.get("msg_id")));
                            data.put("title", eeuiParse.parseStr(body.get("title")));
                            data.put("subtitle", "");
                            data.put("text", eeuiParse.parseStr(body.get("text")));
                            data.put("extra", extra != null ? extra : new HashMap<>());
                            data.put("rawData", temp);
                            mBean.callback.invokeAndKeepAlive(data);
                            isCallBack = true;
                        }
                        break;
                    }
                }
                if (!isCallBack) {
                    mNotificationClickHandler.set(i, null);
                }
            }
        }
    }

    private static ActivityLifecycleCallbacks mCallbacks = new ActivityLifecycleCallbacks() {
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

        }

        @Override
        public void onActivityStarted(Activity activity) {

        }

        @Override
        public void onActivityResumed(Activity activity) {
            MobclickAgent.onResume(activity);
        }

        @Override
        public void onActivityPaused(Activity activity) {
            MobclickAgent.onPause(activity);
        }

        @Override
        public void onActivityStopped(Activity activity) {

        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }
    };

}
