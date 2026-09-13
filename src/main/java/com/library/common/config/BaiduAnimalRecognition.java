package com.library.common.config;


import com.baidu.aip.imageclassify.AipImageClassify;
import com.library.common.util.ResponseResult;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class BaiduAnimalRecognition {
    // 设置APPID/AK/SK
    private static final String APP_ID = "119657896";
    private static final String API_KEY = "BBT2RqWUytkge0JKqiuIuNCn";
    private static final String SECRET_KEY = "9CcrHGK5LUQVOE7oYMZ6pVqpK4WQp5DY";

    private static AipImageClassify client;

    static {
        client = new AipImageClassify(APP_ID, API_KEY, SECRET_KEY);
        client.setConnectionTimeoutInMillis(2000);
        client.setSocketTimeoutInMillis(60000);

    }

    /**
     * 识别动物并返回标准化结果
     * @param imageBytes 图片字节数组
     * @return ResponseResult 包含识别结果
     */
    public static ResponseResult recognizeAnimal(byte[] imageBytes) {
        try {
            HashMap<String, String> options = new HashMap<>();
            options.put("top_num", "1");
            options.put("baike_num", "1");
            options.put("with_baike", "1"); // 明确要求返回百科信息
            options.put("language", "zh");  // 指定中文结果

            JSONObject apiResponse = client.animalDetect(imageBytes, options);
            return parseApiResponse(apiResponse);
        } catch (Exception e) {
            return ResponseResult.error(500, "动物识别服务异常: " + e.getMessage());
        }
    }

    private static ResponseResult parseApiResponse(JSONObject apiResponse) {
        // 检查API响应是否有效
        if (!apiResponse.has("result") || apiResponse.isNull("result")) {
            return ResponseResult.error(400, "未识别到任何动物");
        }

        JSONArray results = apiResponse.getJSONArray("result");
        if (results.length() == 0) {
            return ResponseResult.error(400, "未识别到任何动物");
        }

        JSONObject topResult = results.getJSONObject(0);
        // 使用Map代替JSONObject
        Map<String, Object> data = new HashMap<>();

        // 基本信息
        data.put("name", topResult.getString("name"));
        data.put("score", topResult.getDouble("score"));

        // 百科信息
        if (topResult.has("baike_info")) {
            JSONObject baikeInfo = topResult.getJSONObject("baike_info");
            data.put("description", baikeInfo.optString("description", "暂无简介"));
            data.put("baikeUrl", baikeInfo.optString("baike_url", ""));
        }

        return ResponseResult.success(data);
    }
}
