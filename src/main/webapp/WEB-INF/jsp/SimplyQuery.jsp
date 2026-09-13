<%--
  Created by IntelliJ IDEA.
  User: 30202
  Date: 2025/7/30
  Time: 11:52
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>物种查询</title>
    <style>
        /* ========== 基础与桌面端样式（保留原有风格，优化部分单位） ========== */
        html {
            font-size: 16px; /* 桌面端基准 */
        }

        * {
            box-sizing: border-box;
        }

        .body {
            width: 100%;
            background-image: url('/images/species/sea3.png');
            min-height: 100vh;
            min-height: 100dvh;
            background-size: cover;
            background-position: center center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            margin: 0;
            font-family: 'Microsoft YaHei', 'PingFang SC', 'Helvetica Neue', sans-serif;
        }

        /* 导航栏 */
        .navbar {
            display: flex;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.40);
            padding: 2vh 0;
            position: relative;
            flex-wrap: nowrap;
            align-items: center;
        }

        .library-name {
            margin-left: 3vw;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-shrink: 0;
        }

        .library-name img {
            width: 4vw;
            height: 4vw;
            min-width: 32px;
            min-height: 32px;
            border-radius: 50%;
        }

        .library-title {
            margin-left: 1vw;
            font-family: 'STXingkai', 'KaiTi', '楷体', 'LiSu', '隶书', cursive;
            font-weight: 800;
            color: black;
            text-shadow: 3px 3px 5px rgba(139, 137, 137, 0.3);
            display: flex;
            flex-direction: column;
            align-items: center;
            white-space: nowrap;
        }

        .library-title div:first-child {
            font-size: 3.5vh;
        }

        .library-title div:last-child {
            font-size: 1.2vh;
            font-family: 'Courier New', Courier, monospace;
            font-weight: 400;
        }

        /* 返回首页按钮 */
        .return {
            width: 120px;
            height: 50px;
            background-color: #2c7ae4;
            color: white;
            border: none;
            border-radius: 25px;
            font-size: 16px;
            font-weight: bold;
            text-align: center;
            line-height: 50px;
            cursor: pointer;
            position: fixed;
            right: 2vw;
            top: 3.5vh;
            z-index: 1000;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
            -webkit-tap-highlight-color: transparent;
            touch-action: manipulation;
        }

        .return:hover {
            background-color: #3070cd;
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
        }

        .return:active {
            transform: translateY(1px);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        /* 搜索容器 */
        .search-container {
            width: 60%;
            height: 7vh;
            min-height: 45px;
            margin-left: 8vw;
            display: flex;
            justify-content: center;
            flex-shrink: 1;
        }

        .search-window {
            border-radius: 3vh;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            background-color: rgba(255, 255, 255, 0.8);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 0 1vh;
            position: relative;
        }

        /* 自定义下拉框 */
        .custom-select {
            text-align: center;
            position: relative;
            width: 8vw;
            min-width: 70px;
            height: 100%;
            cursor: pointer;
            z-index: 10;
            flex-shrink: 0;
        }

        .select-header {
            height: 100%;
            padding: 0 2vw 0 1vw;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            color: #333;
            position: relative;
            width: 100%;
            text-align: center;
        }

        .selected-value {
            flex: 1;
            text-align: center;
            white-space: nowrap;
        }

        .arrow {
            position: absolute;
            right: 0.5vw;
            font-size: 0.7rem;
            transition: transform 0.2s;
        }

        .select-options {
            position: absolute;
            top: 100%;
            left: 0;
            width: 100%;
            max-height: 0;
            overflow: hidden;
            background-color: white;
            border-radius: 0 0 1vh 1vh;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: max-height 0.3s ease-out, opacity 0.2s ease;
            opacity: 0;
            pointer-events: auto;
            margin-top: 5px;
            z-index: 20;
        }

        .custom-select:hover .select-options {
            max-height: 20vh;
            overflow-y: auto;
            border: 1px solid #eee;
            border-top: none;
            opacity: 1;
        }

        .custom-select:hover .arrow {
            transform: rotate(180deg);
        }

        .select-options {
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        .select-options::-webkit-scrollbar {
            display: none;
        }

        .option {
            padding: 0.8vh 0.8vw;
            font-size: 0.9rem;
            color: #333;
            transition: background-color 0.2s;
            white-space: nowrap;
        }

        .option:hover {
            background-color: #f5f5f5;
        }

        .option.selected {
            background-color: #1890ff;
            color: white;
        }

        /* 分隔线 */
        .line {
            margin-left: 2%;
            width: 2px;
            border-radius: 10%;
            height: 70%;
            background-color: #63a8e9;
            flex-shrink: 0;
        }

        /* 搜索输入框 */
        .search-input {
            border-left: 2px solid #1890ff;
            flex: 1;
            height: 80%;
            border: none;
            outline: none;
            background: transparent;
            padding: 0 1vw;
            font-size: 1rem;
            color: #333;
            min-width: 0;
        }

        /* 按钮通用 */
        .search-action,
        .search-submit {
            height: 3vw;
            width: 3vw;
            min-width: 36px;
            min-height: 36px;
            border: none;
            border-radius: 50%;
            margin-left: 0.5vw;
            font-size: 1rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            flex-shrink: 0;
            -webkit-tap-highlight-color: transparent;
            touch-action: manipulation;
        }

        .search-action {
            background-color: #f0f0f0;
            color: #666;
            position: relative;
        }

        .search-action img {
            width: 2vw;
            height: 2vw;
            min-width: 18px;
            min-height: 18px;
        }

        .search-submit {
            background-color: #1890ff;
            color: white;
        }

        .search-submit img {
            width: 2vw;
            height: 2vw;
            min-width: 18px;
            min-height: 18px;
        }

        .search-action:hover {
            background-color: #e0e0e0;
        }

        .search-submit:hover {
            background-color: #1478d4;
        }

        /* 上传图片预览框 */
        .uploadImage {
            position: absolute;
            font-size: 12px;
            width: 8vw;
            min-width: 90px;
            height: auto;
            min-height: 40px;
            top: 7vh;
            background-color: white;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            padding: 8px;
            animation: fadeIn 0.3s ease;
            display: none;
            flex-direction: column;
            align-items: center;
            z-index: 30;
            right: 0;
        }

        .uploadImage .preview-icon {
            width: 22px;
            height: 22px;
            margin-bottom: 4px;
            object-fit: cover;
            border-radius: 3px;
        }

        .uploadImage .file-name {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100%;
            font-size: 10px;
        }

        .chacha {
            position: absolute;
            width: 16px;
            height: 16px;
            right: -5px;
            top: -5px;
            cursor: pointer;
            opacity: 0.8;
            transition: opacity 0.2s;
        }

        .chacha:hover {
            opacity: 1;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-5px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 结果展示区域 */
        .result-box {
            width: 80vw;
            max-width: 1200px;
            min-height: 80vh;
            background-color: rgba(255, 255, 255, 0.7);
            margin: 5vh auto;
            border-radius: 1vh;
            padding-bottom: 20px;
        }

        .result-title {
            height: 8vh;
            min-height: 50px;
            width: 60%;
            text-align: center;
            margin: auto;
            display: flex;
            flex-direction: column;
            justify-content: center;
            font-family: "STXingkai", "KaiTi", "楷体", cursive;
            font-size: 36px;
            color: #5e2c04;
            position: relative;
            border: 1px solid #1478d4;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            background-color: rgba(179, 211, 241, 0.5);
        }

        .result-title::before,
        .result-title::after {
            content: "";
            position: absolute;
            height: 50px;
            width: 20px;
            background: #1478d4;
            top: 50%;
            transform: translateY(-50%);
        }

        .result-title::before {
            left: -10px;
        }
        .result-title::after {
            right: -10px;
        }

        .result-content {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-top: 20px;
        }

        .left-box {
            width: 36%;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .middle-line {
            width: 0.1vw;
            min-width: 1px;
            background-color: #1890ff;
            border-radius: 10px;
            align-self: stretch;
            margin: 0 10px;
            flex-shrink: 0;
        }

        .right-box {
            width: 63%;
            min-height: 100%;
        }

        .result-image {
            width: 90%;
            max-width: 300px;
            margin: 5vh auto 0;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
        }

        .result-image img {
            width: 100%;
            height: auto;
            max-height: 250px;
            object-fit: contain;
        }

        .result-name {
            margin-top: 2vh;
            width: 60%;
            text-align: center;
            font-size: 28px;
            font-weight: 600;
            color: #333;
        }

        .result-class {
            width: 100%;
            margin-top: 2vh;
        }

        .class {
            width: 80%;
            margin: auto auto 1.5vh;
            padding: 8px;
            text-align: left;
            font-size: 22px;
            color: #222;
        }

        .class-content {
            margin-left: 15px;
            color: #303031;
            font-weight: normal;
        }

        .right-title {
            width: 90%;
            padding: 15px 20px;
            font-size: 28px;
            font-weight: 600;
            margin: 3vh auto 0;
            color: #1478d4;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .hline {
            width: 90%;
            height: 2px;
            margin: 5px auto;
            background-color: #1478d4;
        }

        .content {
            width: 90%;
            margin: 2vh auto;
            font-size: 18px;
            line-height: 1.7;
            color: #333;
        }

        #description {
            white-space: pre-line;
        }

        /* 加载动画 */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            color: white;
            font-size: 1.5rem;
        }

        .loading-spinner {
            border: 5px solid #f3f3f3;
            border-top: 5px solid #3498db;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* 模态框 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            padding: 15px;
        }

        .modal-content {
            background-color: #fefefe;
            padding: 20px;
            border-radius: 10px;
            width: 65%;
            max-width: 60vw;
            max-height: 80vh;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            animation: modalFadeIn 0.3s;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .close {
            position: absolute;
            right: 15px;
            top: 15px;
            width: 36px;
            height: 36px;
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 5;
        }

        .close:hover {
            color: black;
        }

        .result-container {
            overflow-y: auto;
            max-height: calc(80vh - 120px);
            padding-right: 8px;
            margin-bottom: 10px;
            -webkit-overflow-scrolling: touch;
        }

        .result-container::-webkit-scrollbar {
            width: 6px;
        }
        .result-container::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }
        .result-container::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 3px;
        }

        .resultTitle {
            color: #1890ff;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }

        .result-item {
            margin-bottom: 10px;
        }

        .result-label {
            font-weight: bold;
            color: #333;
        }

        .result-value {
            color: #666;
        }

        .resultImage {
            max-width: 100%;
            max-height: 200px;
            display: block;
            margin: 15px auto;
            border-radius: 5px;
            object-fit: contain;
        }

        .result-description {
            margin-top: 15px;
            padding: 10px;
            background-color: #f9f9f9;
            border-radius: 5px;
            line-height: 1.6;
            font-size: 14px;
        }

        /* ========== 移动端适配 (宽度 ≤ 768px) ========== */
        @media (max-width: 768px) {
            html {
                font-size: 15px;
            }

            .body {
                background-attachment: scroll; /* 移动端fixed可能有性能问题 */
            }

            /* 导航栏 */
            .navbar {
                padding: 1vh 1vw;
                flex-wrap: wrap;
                justify-content: space-between;
            }

            .library-name {
                margin-left: 2vw;
                transform: scale(0.9);
                transform-origin: left center;
            }

            .library-name img {
                width: 8vw;
                height: 8vw;
                min-width: 28px;
                min-height: 28px;
            }

            .library-title div:first-child {
                font-size: 2.5vh;
            }
            .library-title div:last-child {
                font-size: 1vh;
            }

            /* 返回按钮调整位置，避免遮挡 */
            .return {
                width: 100px;
                height: 40px;
                line-height: 40px;
                font-size: 14px;
                right: 3vw;
                top: 2vh;
                border-radius: 20px;
            }

            /* 搜索容器全宽 */
            .search-container {
                width: 100%;
                margin: 10px 2vw;
                height: auto;
                min-height: 45px;
                order: 3;
                flex-basis: 100%;
            }

            .search-window {
                border-radius: 22px;
                height: 45px;
                padding: 0 8px;
                flex-wrap: nowrap;
            }

            .custom-select {
                width: auto;
                min-width: 60px;
                flex-shrink: 0;
            }

            .select-header {
                font-size: 0.9rem;
                padding: 0 8px;
            }

            .arrow {
                right: 2px;
                font-size: 0.6rem;
            }

            .option {
                font-size: 0.8rem;
                padding: 10px 8px;
            }

            .line {
                margin-left: 4px;
                height: 60%;
            }

            .search-input {
                font-size: 0.9rem;
                padding: 0 6px;
            }

            .search-action,
            .search-submit {
                height: 32px;
                width: 32px;
                min-width: 32px;
                min-height: 32px;
                margin-left: 4px;
            }

            .search-action img,
            .search-submit img {
                width: 18px;
                height: 18px;
            }

            .uploadImage {
                width: auto;
                min-width: 100px;
                right: 0;
                top: 50px;
            }

            /* 结果区域改为上下布局 */
            .result-box {
                width: 95vw;
                margin: 3vh auto;
                min-height: auto;
            }

            .result-title {
                width: 80%;
                font-size: 26px;
                height: auto;
                padding: 10px 0;
                margin-top: 10px;
            }

            .result-title::before,
            .result-title::after {
                height: 30px;
                width: 12px;
            }
            .result-title::before {
                left: -6px;
            }
            .result-title::after {
                right: -6px;
            }

            .result-content {
                flex-direction: column;
                align-items: center;
            }

            .left-box {
                width: 90%;
                flex-direction: column;
                align-items: center;
                margin-bottom: 20px;
            }

            .middle-line {
                display: none; /* 移动端隐藏竖线 */
            }

            .right-box {
                width: 90%;
            }

            .result-image {
                width: 70%;
                max-width: 250px;
                margin: 2vh auto;
            }

            .result-image img {
                max-height: 200px;
            }

            .result-name {
                width: 80%;
                font-size: 24px;
                margin-top: 1vh;
            }

            .result-class {
                width: 90%;
                margin-top: 1vh;
            }

            .class {
                width: 100%;
                font-size: 18px;
                padding: 4px;
                margin-bottom: 1vh;
            }

            .class-content {
                margin-left: 10px;
            }

            .right-title {
                font-size: 24px;
                padding: 10px 0;
                text-align: center;
            }

            .content {
                font-size: 16px;
            }

            /* 模态框 */
            .modal-content {
                width: 92%;
                max-width: 92vw;
                max-height: 85vh;
                padding: 15px;
                margin: 3% auto;
            }

            .result-container {
                max-height: calc(85vh - 100px);
            }

            .close {
                right: 10px;
                top: 10px;
                width: 30px;
                height: 30px;
                font-size: 24px;
            }

            .resultImage {
                max-height: 150px;
            }

            .result-description {
                font-size: 13px;
            }

            .loading-overlay {
                font-size: 1.2rem;
            }

            .loading-spinner {
                width: 40px;
                height: 40px;
            }
        }

        /* ========== 小屏手机优化 (宽度 ≤ 480px) ========== */
        @media (max-width: 480px) {
            html {
                font-size: 14px;
            }

            .library-name img {
                width: 10vw;
                height: 10vw;
                min-width: 24px;
                min-height: 24px;
            }

            .library-title div:first-child {
                font-size: 2vh;
            }
            .library-title div:last-child {
                font-size: 0.8vh;
            }

            .return {
                width: 80px;
                height: 34px;
                line-height: 34px;
                font-size: 12px;
                right: 2vw;
                top: 1.5vh;
            }

            .search-window {
                height: 40px;
                padding: 0 4px;
            }

            .custom-select {
                min-width: 50px;
            }

            .select-header {
                font-size: 0.8rem;
            }

            .search-input {
                font-size: 0.8rem;
            }

            .search-action,
            .search-submit {
                height: 28px;
                width: 28px;
                min-width: 28px;
                min-height: 28px;
            }

            .search-action img,
            .search-submit img {
                width: 15px;
                height: 15px;
            }

            .result-title {
                font-size: 22px;
            }

            .result-name {
                font-size: 20px;
            }

            .class {
                font-size: 16px;
            }

            .right-title {
                font-size: 20px;
            }

            .content {
                font-size: 14px;
            }

            .resultImage {
                max-height: 120px;
            }

            .modal-content {
                width: 96%;
                max-width: 96vw;
                padding: 12px;
            }

            .uploadImage {
                min-width: 80px;
                padding: 5px;
                font-size: 10px;
            }
        }
    </style>
</head>

<body>
<div class="loading-overlay" id="loadingOverlay" style="display: none;">
    <div class="loading-spinner"></div>
    <div class="loading-text">正在加载数据...</div>
</div>
<div class="body">
    <div class="navbar">
        <div class="library-name">
            <div><img src="/images/newlogo.png" alt=""></div>
            <div class="library-title">
                <div>海洋生物图鉴</div>
                <div>WHALEQUEST: MARINE BIO EXPLORER</div>
            </div>
        </div>
        <div class="search-container">
            <div class="search-window">
                <!-- 自定义下拉框 -->
                <div class="custom-select">
                    <div class="select-header">
                        <span class="selected-value">鱼类</span>
                        <span class="arrow">▼</span>
                    </div>
                    <div class="select-options">
                        <div class="option selected" data-value="鱼类">鱼类</div>
                        <div class="option" data-value="哺乳类">哺乳类</div>
                        <div class="option" data-value="无脊椎类">无脊椎类</div>
                    </div>
                    <select name="category" class="original-select" style="display:none">
                        <option value="鱼类" selected>鱼类</option>
                        <option value="哺乳类">哺乳类</option>
                        <option value="无脊椎类">无脊椎类</option>
                    </select>
                </div>
                <div class="line"></div>
                <input type="text" class="search-input" placeholder="请输入物种名称...">
                <button class="search-action">
                    <img src="/images/index/237.png" alt="">
                    <div class="uploadImage" style="display: none;">
                        <img src="/images/index/picture.png" class="preview-icon" alt="">
                        <span class="file-name">图片5685.png</span>
                        <img src="/images/index/No.png" class="chacha" alt="删除">
                    </div>
                </button>
                <input type="file" id="fileInput" accept="image/*" style="display: none;">
                <div class="line"></div>
                <button class="search-submit">
                    <img src="/images/index/search.png" alt="搜索">
                </button>
            </div>
        </div>

        <div class="return" onclick="window.location.href='/index'">
            <i class="fas fa-home" style="margin-right: 5px;"></i> 回到首页
        </div>
    </div>
    <div class="result-box">
        <div class="result-title">
            查询结果
        </div>
        <div class="result-content">
            <div class="left-box">
                <div class="result-image"><img id="resultImage" src="" alt=""></div>
                <div class="result-name" id="resultName"></div>
                <div class="result-class">
                    <div class="class">纲:<span class="class-content" id="class"></span></div>
                    <div class="class">目:<span class="class-content" id="order"></span></div>
                    <div class="class">科:<span class="class-content" id="family"></span></div>
                </div>
            </div>
            <div class="middle-line"></div>
            <div class="right-box">
                <div class="right-title">简介</div>
                <div class="hline"></div>
                <div class="content" id="description"></div>
            </div>
        </div>
    </div>
</div>

<!-- 识别结果模态框 -->
<div id="recognitionModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <h2 class="resultTitle">海洋生物识别结果</h2>
        <div class="result-container" id="recognitionResult">
            <!-- 结果内容将通过JavaScript动态填充 -->
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        // 初始化下拉选择框
        const customSelects = document.querySelectorAll('.custom-select');
        customSelects.forEach(select => {
            const header = select.querySelector('.select-header');
            const selectedValue = select.querySelector('.selected-value');
            const options = select.querySelectorAll('.option');
            const originalSelect = select.querySelector('.original-select');

            const initialOption = originalSelect.querySelector('option:checked') ||
                originalSelect.querySelector('option');
            if (initialOption) {
                selectedValue.textContent = initialOption.textContent;
                originalSelect.value = initialOption.value;
                options[0].classList.add('selected');
            }

            options.forEach(option => {
                option.addEventListener('click', function () {
                    selectedValue.textContent = this.textContent;
                    originalSelect.value = this.dataset.value;

                    options.forEach(opt => opt.classList.remove('selected'));
                    this.classList.add('selected');

                    const event = new Event('change');
                    originalSelect.dispatchEvent(event);
                });
            });
        });

        // 图片上传相关功能
        const searchActionBtn = document.querySelector('.search-action');
        const fileInput = document.getElementById('fileInput');
        const uploadImageBox = document.querySelector('.uploadImage');
        let currentFile = null;

        searchActionBtn.addEventListener('click', function () {
            fileInput.click();
        });

        fileInput.addEventListener('change', function (e) {
            const file = e.target.files[0];
            if (file) {
                if (!file.type.startsWith('image/')) {
                    alert('请选择有效的图片文件！');
                    return;
                }

                currentFile = file;

                const previewIcon = uploadImageBox.querySelector('.preview-icon');
                const fileNameSpan = uploadImageBox.querySelector('.file-name');

                fileNameSpan.textContent = file.name;

                const reader = new FileReader();
                reader.onload = function (e) {
                    previewIcon.src = e.target.result;
                    uploadImageBox.style.display = 'flex';
                };
                reader.readAsDataURL(file);
            }
        });

        uploadImageBox.querySelector('.chacha').addEventListener('click', function (e) {
            e.stopPropagation();
            resetUploadPreview();
        });

        const searchSubmitBtn = document.querySelector('.search-submit');
        const searchInput = document.querySelector('.search-input');
        const originalSelect = document.querySelector('.original-select');

        searchSubmitBtn.addEventListener('click', async function() {
            if (currentFile) {
                try {
                    uploadImageBox.innerHTML = '<div style="padding:10px;">识别中，请稍候...</div>';

                    const formData = new FormData();
                    formData.append('image', currentFile);

                    const response = await fetch('/ai/recognize', {
                        method: 'POST',
                        body: formData
                    });

                    const data = await response.json();

                    if (data.code === 200 && data.data && data.data.data) {
                        const result = data.data.data;
                        showRecognitionResult(result);
                    } else {
                        throw new Error(data.message || '识别失败');
                    }
                } catch (error) {
                    console.error('识别失败:', error);
                    uploadImageBox.innerHTML = `
                        <div style="padding:10px;color:red;">
                            <p>识别失败: ${error.message}</p>
                            <img src="/images/index/No.png" class="chacha" alt="删除"
                                 style="position:absolute;right:-5px;top:-5px;cursor:pointer;">
                        </div>
                    `;
                    uploadImageBox.querySelector('.chacha').addEventListener('click', function(e) {
                        e.stopPropagation();
                        resetUploadPreview();
                    });
                }
            } else {
                const speciesName = searchInput.value.trim();
                const speciesClass = originalSelect.value;

                if (speciesName) {
                    searchByText(speciesName, speciesClass);
                } else {
                    alert('请输入物种名称或上传图片');
                }
            }
        });

        function searchByText(name, category) {
            document.getElementById('loadingOverlay').style.display = 'flex';

            let apiUrl = '';
            if (category === "鱼类") {
                apiUrl = '/FishSpecies/search?name=' + name;
            } else if (category === '哺乳类') {
                apiUrl = '/WhaleSpecies/search?name=' + name;
            } else if (category === '无脊椎类') {
                apiUrl = '/invertebrate/search?name=' + name;
            }

            fetch(apiUrl)
                .then(response => response.json())
                .then(data => {
                    if (data.code === 200) {
                        const species = data.data;
                        if (!species) {
                            throw new Error('未找到该物种信息');
                        }
                        showTextSearchResult(species);
                    } else {
                        throw new Error(data.message || '获取物种信息失败');
                    }
                })
                .catch(error => {
                    console.error('搜索失败:', error);
                    alert(error.message);
                })
                .finally(() => {
                    document.getElementById('loadingOverlay').style.display = 'none';
                });
        }

        function showTextSearchResult(species) {
            const resultImage = document.getElementById('resultImage');
            resultImage.style.visibility = 'hidden';
            resultImage.src = species.imageUrl || '';

            resultImage.onload = function() {
                document.getElementById('resultName').textContent = species.name;
                document.getElementById('class').textContent = species.fishClass || species.animalClass;
                document.getElementById('order').textContent = species.order;
                document.getElementById('family').textContent = species.family;
                document.getElementById('description').textContent = species.description;
                resultImage.style.visibility = 'visible';
            };

            resultImage.onerror = function() {
                console.warn('图片加载失败，使用备用图片');
                resultImage.src = '/images/default-species.png';
                document.getElementById('resultName').textContent = species.name;
                document.getElementById('class').textContent = species.fishClass || species.animalClass;
                document.getElementById('order').textContent = species.order;
                document.getElementById('family').textContent = species.family;
                document.getElementById('description').textContent = species.description;
                resultImage.style.visibility = 'visible';
            };
        }

        function resetUploadPreview() {
            uploadImageBox.innerHTML = `
                <img src="/images/index/picture.png" class="preview-icon" style="width: 22px;height: 22px;" alt="">
                <span class="file-name"></span>
                <img src="/images/index/No.png" class="chacha" alt="删除">
            `;
            uploadImageBox.style.display = 'none';
            fileInput.value = '';
            currentFile = null;

            uploadImageBox.querySelector('.chacha').addEventListener('click', function(e) {
                e.stopPropagation();
                resetUploadPreview();
            });
        }

        function showRecognitionResult(result) {
            const resultContainer = document.getElementById('recognitionResult');
            resultContainer.innerHTML = `
                <div class="result-item">
                    <span class="result-label">名称:</span>
                    <span class="result-value">${result.name}</span>
                </div>
                <div class="result-item">
                    <span class="result-label">纲:</span>
                    <span class="result-value">${result.animalClass}</span>
                </div>
                <div class="result-item">
                    <span class="result-label">目:</span>
                    <span class="result-value">${result.order}</span>
                </div>
                <div class="result-item">
                    <span class="result-label">科:</span>
                    <span class="result-value">${result.family}</span>
                </div>
                ${result.imageUrl ? `<img src="${result.imageUrl}" class="resultImage" alt="${result.name}">` : ''}
                <div class="result-description">
                    ${result.description || '暂无详细描述'}
                </div>
            `;
            document.getElementById('recognitionModal').style.display = "flex";
            resetUploadPreview();
        }

        document.querySelector('.close').onclick = function() {
            document.getElementById('recognitionModal').style.display = "none";
        }

        window.onclick = function(event) {
            if (event.target == document.getElementById('recognitionModal')) {
                document.getElementById('recognitionModal').style.display = "none";
            }
        }

        // 从URL获取查询参数并自动搜索
        const urlParams = new URLSearchParams(window.location.search);
        const speciesName = urlParams.get('name');
        const speciesClass = urlParams.get('category');

        if (speciesName && speciesClass) {
            searchByText(speciesName, speciesClass);
        }
    });
</script>
</body>
</html>