<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>首页 - 海洋生物图鉴</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            -webkit-tap-highlight-color: transparent;
        }

        .body {
            width: 100%;
            min-height: 100vh;
            min-height: 100dvh;
            background-image: url('/images/index/newSea.png');
            background-size: cover;
            background-position: center;
            margin: 0;
            display: flex;
            flex-direction: column;
        }

        .navbar {
            display: flex;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.40);
            padding: 2vh 0;
            flex-shrink: 0;
            align-items: center;
        }

        .navbar a {
            color: white;
            padding: 1vw 2vh;
            text-decoration: none;
            text-align: center;
        }

        .dropdown {
            float: left;
            overflow: hidden;
        }

        .dropdown .dropbtn {
            cursor: pointer;
            width: 9vw;
            height: 8vh;
            font-size: 1.2vw;
            line-height: 1.2vw;
            font-family: 'Gill Sans', 'Gill Sans MT', Calibri, 'Trebuchet MS', sans-serif;
            font-weight: 500;
            border: none;
            outline: none;
            color: white;
            text-align: center;
            background-color: inherit;
            font-family: inherit;
            margin: 0;
            white-space: nowrap;
            transition: color 0.3s;
        }

        .dropbtn:hover,
        .dropdown:hover .dropbtn {
            color: yellow
        }

        .changed {
            border-bottom: 0.5vh solid orange;
        }

        .navbar a:hover,
        .dropbtn {
            background-color: #ddd;
        }

        .dropdown:hover {
            display: block;
        }

        .login-status {
            display: flex;
            align-items: center;
        }

        .login-status img {
            width: 1.6vw;
            height: 1.6vw;
            border-radius: 50%;
            margin-right: 1vw;
        }

        .login-status span {
            color: white;
            padding: 1vw 2vh;
        }

        .right {
            position: absolute;
            right: 0;
            width: 15vw;
            height: 8vh;
            line-height: 8vh;
            color: white;
            display: flex;
        }

        .right img {
            width: 5vh;
            height: 5vh;
            margin: auto;
        }

        .title {
            width: 10vw;
            height: 100%;
            background-color: aqua;
        }

        .library-name {
            margin-left: 3vw;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-shrink: 0;
        }

        .library-title {
            margin-left: 1vw;
            font-family: 楷体;
            font-weight: 800;
            color: black;
            text-shadow: 3px 3px 5px rgba(139, 137, 137, 0.3);
            font-weight: 300;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .left-nav {
            display: flex;
            align-items: center;
        }

        .search {
            margin-top: 12vh;
            width: 100%;
            flex-shrink: 0;
        }

        .search-container {
            width: 65%;
            height: 8vh;
            margin: 10vh auto 0;
            display: flex;
            justify-content: center;
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

        .custom-select {
            text-align: center;
            position: relative;
            width: 10vw;
            height: 100%;
            cursor: pointer;
            z-index: 10;
        }

        .select-header {
            height: 100%;
            padding: 0 2vw 0 1vw;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2vw;
            color: #333;
            position: relative;
            width: 80%;
            text-align: center;
        }

        .selected-value {
            flex: 1;
            text-align: center;
        }

        .arrow {
            position: absolute;
            right: 1vw;
            font-size: 0.8vw;
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
            transition: max-height 0.3s ease-out;
            scrollbar-width: none;
            -ms-overflow-style: none;
            opacity: 0;
            pointer-events: none;
        }

        .custom-select:hover .select-options {
            max-height: 20vh;
            overflow-y: auto;
            border: 1px solid #eee;
            border-top: none;
            opacity: 1;
            pointer-events: auto;
        }

        .custom-select:hover .arrow {
            transform: rotate(180deg);
        }

        .option {
            padding: 1vh 1vw;
            font-size: 1.1vw;
            color: #333;
            transition: background-color 0.2s;
        }

        .option:hover {
            background-color: #f5f5f5;
        }

        .option.selected {
            background-color: #1890ff;
            color: white;
        }

        .search-input {
            border-left: 2px solid #1890ff;
            flex: 1;
            height: 80%;
            border: none;
            outline: none;
            background: transparent;
            padding: 0 1vw;
            font-size: 1.2vw;
            color: #333;
        }

        .search-action {
            height: 3vw;
            width: 3vw;
            border: none;
            border-radius: 50%;
            padding: 0 1.5vw;
            margin-left: 1vw;
            font-size: 1.1vw;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            position: relative;
        }

        .search-submit {
            height: 3.5vw;
            width: 3.5vw;
            border: none;
            border-radius: 50%;
            margin-left: 1vw;
            margin-right: 0.5vw;
            font-size: 1.1vw;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }

        .search-action {
            background-color: #f0f0f0;
            color: #666;
            position: relative;
        }

        .uploadImage {
            position: absolute;
            font-size: 12px;
            width: 8vw;
            height: 5vh;
            text-align: center;
            display: flex;
            justify-content: center;
            flex-direction: column;
            align-items: center;
            top: 7vh;
            background-color: white;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            padding: 8px;
            animation: fadeIn 0.3s ease;
            display: none;
        }

        .uploadImage .preview-icon {
            margin-bottom: 4px;
        }

        .uploadImage .file-name {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100%;
        }

        .chacha {
            position: absolute;
            width: 15px;
            height: 15px;
            right: -3px;
            top: -3px;
            cursor: pointer;
            opacity: 0.7;
            transition: opacity 0.2s;
        }

        .chacha:hover {
            opacity: 1;
        }

        .search-submit {
            background-color: #1890ff;
            color: white;
        }

        .search-action:hover {
            background-color: #e0e0e0;
        }

        .search-submit:hover {
            background-color: #1478d4;
        }

        .line {
            margin-left: 2%;
            width: 2px;
            border-radius: 10%;
            height: 70%;
            background-color: #63a8e9;
        }

        .statistics {
            width: 50%;
            margin: auto;
            height: 14vh;
            display: flex;
            justify-content: space-between;
            flex-shrink: 0;
        }

        .box {
            width: 20%;
            height: 100%;
            background-color: rgba(178, 227, 240, 0.8);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            transition: transform 0.3s ease;
        }

        .box:hover {
            transform: scale(1.05);
        }

        .number {
            width: 100%;
            height: 70%;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            font-size: 30px;
            font-weight: 600;
            color: rgb(56, 56, 56);
            border-top: 3px solid rgb(0, 157, 255);
        }

        .T {
            width: 100%;
            height: 30%;
            text-align: center;
            font-size: 22px;
            font-weight: 400;
            color: white;
        }

        .shujuBox {
            width: 100%;
            flex: 1;
            display: flex;
            background-image: url('/images/DataBase/3.jpg');
            background-size: cover;
            min-height: 45vh;
        }

        .shujuBox>div {
            width: 90%;
            height: 90%;
            background-color: rgba(255, 255, 255, 0.5);
            margin: auto;
            display: flex;
            border-radius: 20px;
        }

        .shujuBox-left {
            width: 100%;
            height: 85%;
            background-color: transparent;
        }

        .shujuBox-header {
            display: flex;
            flex-direction: column;
            justify-content: center;
            width: 28%;
            height: 42%;
            margin: auto;
            font-size: 1.8vw;
            font-weight: bold;
            text-align: center;
            color: rgb(28, 147, 238);
            background-image: url('/images/DataBase/whale.png');
            background-size: 100% 100%;
            background-position: center;
            background-repeat: no-repeat;
        }

        .shujuBox-bottom {
            width: 100%;
            height: 70%;
            display: flex;
            justify-content: space-around;
            flex-wrap: wrap;
            background-color: rgba(255, 255, 255, 0.5);
            padding-top: 10px;
        }

        .shujuBox-bottom>div {
            width: 17%;
            height: 45%;
            margin-bottom: 10px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .images {
            width: 100%;
            height: 70%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .images>img {
            max-width: 95%;
            max-height: 100%;
            object-fit: contain;
            border: 5px solid #0056b3;
        }

        .images-title {
            margin-top: 9px;
            color: rgb(75, 74, 74);
            font-size: 14px;
            text-align: center;
        }

        .images img {
            transition: transform 0.3s ease;
        }

        .images:hover img {
            transform: scale(1.05);
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
        }

        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
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

        .result-container {
            overflow-y: auto;
            max-height: calc(80vh - 120px);
            padding-right: 10px;
            margin-bottom: 15px;
        }

        .result-container::-webkit-scrollbar {
            width: 8px;
        }

        .result-container::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }

        .result-container::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 4px;
        }

        .result-container::-webkit-scrollbar-thumb:hover {
            background: #555;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .close {
            position: absolute;
            right: 20px;
            top: 20px;
            width: 40px;
            height: 40px;
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }

        .close:hover {
            color: black;
        }

        .result-title {
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

        .result-image {
            max-width: 100%;
            max-height: 200px;
            display: block;
            margin: 15px auto;
            border-radius: 5px;
        }

        .result-description {
            margin-top: 15px;
            padding: 10px;
            background-color: #f9f9f9;
            border-radius: 5px;
            line-height: 1.6;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeOut {
            from { opacity: 1; transform: translateY(0); }
            to { opacity: 0; transform: translateY(10px); }
        }

        /* ==================== 移动端适配 ==================== */
        @media (max-width: 768px) {
            .body {
                min-height: 100vh;
                min-height: 100dvh;
            }

            .navbar {
                flex-wrap: nowrap;
                overflow-x: auto;
                overflow-y: hidden;
                -webkit-overflow-scrolling: touch;
                scrollbar-width: none;
                -ms-overflow-style: none;
                padding: 8px 5px;
                gap: 0;
            }

            .navbar::-webkit-scrollbar {
                display: none;
            }

            .library-name {
                margin-left: 8px;
                flex-shrink: 0;
            }

            .library-name img {
                width: 36px !important;
                height: 36px !important;
            }

            .library-title div:first-child {
                font-size: 18px !important;
            }

            .library-title div:last-child {
                font-size: 9px !important;
            }

            .left-nav {
                margin-left: 8px !important;
                display: flex;
                flex-wrap: nowrap;
                align-items: center;
                gap: 4px;
                flex-shrink: 0;
            }

            .dropdown .dropbtn {
                width: auto;
                min-width: 44px;
                height: auto;
                padding: 8px 6px;
                font-size: 13px;
                line-height: 1.2;
                border-radius: 6px;
            }

            .right {
                position: static;
                width: auto;
                height: auto;
                line-height: normal;
                flex-shrink: 0;
                margin-left: auto;
                padding-right: 5px;
                font-size: 11px;
                white-space: nowrap;
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .right img {
                width: 24px;
                height: 24px;
                margin: 0;
            }

            .search {
                margin-top: 5vh;
            }

            .search-container {
                width: 90%;
                height: auto;
                margin-top: 3vh;
            }

            .search-window {
                flex-wrap: wrap;
                height: auto;
                padding: 10px;
                border-radius: 20px;
            }

            .custom-select {
                width: 100%;
                height: 40px;
                margin-bottom: 8px;
            }

            .select-header {
                font-size: 15px;
                padding: 0 10px;
            }

            .arrow {
                font-size: 12px;
                right: 10px;
            }

            .option {
                font-size: 14px;
                padding: 8px 10px;
            }

            .line {
                display: none;
            }

            .search-input {
                width: 100%;
                height: 40px;
                font-size: 15px;
                margin-bottom: 8px;
                border-left: none;
                border-bottom: 2px solid #1890ff;
                padding: 0 5px;
            }

            .search-action {
                width: 40px;
                height: 40px;
                margin: 0 4px;
                flex-shrink: 0;
            }

            .search-submit {
                width: 44px;
                height: 44px;
                margin: 0 4px;
                flex-shrink: 0;
            }

            .search-action img,
            .search-submit img {
                width: 20px !important;
                height: 20px !important;
            }

            .uploadImage {
                width: auto;
                max-width: 160px;
                left: 50%;
                transform: translateX(-50%);
            }

            .statistics {
                width: 90%;
                height: auto;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 15px;
            }

            .box {
                width: 45%;
                height: auto;
                min-height: 70px;
                flex-grow: 1;
            }

            .number {
                font-size: 24px;
                height: auto;
                padding: 5px 0;
            }

            .T {
                font-size: 16px;
                height: auto;
                padding: 3px 0;
            }

            .shujuBox {
                min-height: auto;
                padding: 15px 0;
            }

            .shujuBox>div {
                width: 95%;
                height: auto;
            }

            .shujuBox-header {
                width: 60%;
                height: auto;
                font-size: 5vw;
                padding: 20px 0;
            }

            .shujuBox-bottom {
                height: auto;
                padding: 10px;
            }

            .shujuBox-bottom>div {
                width: 30%;
                height: auto;
                min-height: 80px;
                margin-bottom: 8px;
            }

            .images {
                height: auto;
            }

            .images>img {
                max-width: 80%;
                max-height: 60px;
                border-width: 3px;
            }

            .images-title {
                font-size: 10px;
                margin-top: 4px;
            }

            .modal-content {
                width: 90%;
                max-width: 90vw;
                margin: 10% auto;
                padding: 15px;
            }

            .result-container {
                max-height: calc(80vh - 100px);
            }
        }

        @media (max-width: 400px) {
            .dropdown .dropbtn {
                font-size: 11px;
                padding: 6px 4px;
                min-width: 36px;
            }

            .library-title div:first-child {
                font-size: 15px !important;
            }

            .box {
                width: 45%;
            }

            .number {
                font-size: 20px;
            }

            .T {
                font-size: 13px;
            }

            .shujuBox-bottom>div {
                width: 28%;
            }

            .images-title {
                font-size: 9px;
            }
        }
    </style>
</head>

<body>
<div class="body">
    <div class="navbar">
        <div class="library-name">
            <div><img style="width: 4vw;height: 4vw;border-radius: 50%;" src="/images/newlogo.png" alt=""></div>
            <div class="library-title">
                <div style="font-size: 3.5vh; font-family: 'STXingkai', 'KaiTi', '楷体', 'LiSu', '隶书', cursive;">
                    海洋生物图鉴
                </div>
                <div style="font-size: 1.2vh; font-family: 'Courier New', Courier, monospace; font-weight: 400;">
                    WHALEQUEST
                </div>
            </div>
        </div>
        <div class="left-nav" style="margin-left: 50px;">
            <div class="dropdown changed">
                <button class="dropbtn" style="color: yellow;">首页</button>
            </div>
            <div class="dropdown" onclick="window.location.href='/classfiyQuery'">
                <button class="dropbtn">档案查询</button>
            </div>
            <div class="dropdown" onclick="window.location.href='/aiRobot'">
                <button class="dropbtn">AI助手</button>
            </div>
            <div class="dropdown" onclick="window.location.href='/show'">
                <button class="dropbtn">生物图谱</button>
            </div>
            <div class="dropdown" onclick="window.location.href='/defendSea'">
                <button class="dropbtn">保护专区</button>
            </div>
            <div class="dropdown" onclick="window.location.href='/playGame'">
                <button class="dropbtn">科普游戏</button>
            </div>
            <div class="right">
                <div>欢迎,游客！</div>
                <img src="/images/index/happy.png" alt="">
            </div>
        </div>
    </div>

    <div class="search">
        <div class="search-container">
            <div class="search-window">
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
                    <img style="width: 2vw;height: 2vw;" src="/images/index/picture.png" alt="">
                    <div class="uploadImage" style="display: none;">
                        <img src="" class="preview-icon" style="width: 22px;height: 22px;" alt="">
                        <span class="file-name"></span>
                        <img src="/images/index/No.png" class="chacha" alt="删除">
                    </div>
                </button>
                <input type="file" id="fileInput" accept="image/*" style="display: none;">
                <div class="line"></div>
                <button class="search-submit">
                    <img src="/images/index/search.png" style="width: 2.5vw;height: 2.5vw;" alt="搜索">
                </button>
            </div>
        </div>
    </div>

    <div class="statistics">
        <div class="box">
            <div class="T">物种纲数</div>
            <div class="number" id="classCount">0</div>
        </div>
        <div class="box">
            <div class="T">物种目数</div>
            <div class="number" id="orderCount">0</div>
        </div>
        <div class="box">
            <div class="T">物种科数</div>
            <div class="number" id="familyCount">0</div>
        </div>
        <div class="box">
            <div class="T">物种数量</div>
            <div class="number" id="speciesCount">0</div>
        </div>
    </div>
</div>

<div class="shujuBox">
    <div>
        <div class="shujuBox-left">
            <div class="shujuBox-header">
                <div style="mix-blend-mode: difference;color: white;">&nbsp;&nbsp;&nbsp;&nbsp;海洋生物数据库</div>
            </div>
            <div class="shujuBox-bottom">
                <div onclick="window.open('https://www.algaebase.org/', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="./images/DataBase/AlgaeBase.png" alt=""></div>
                    <div class="images-title">AlgaeBase</div>
                </div>
                <div onclick="window.open('https://obis.org/', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/BIS.png" alt=""></div>
                    <div class="images-title">OBIS</div>
                </div>
                <div onclick="window.open('https://marine.copernicus.eu', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/Copernicus.png" alt=""></div>
                    <div class="images-title">Copernicus</div>
                </div>
                <div onclick="window.open('https://www.eol.org/', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/EOL.png" alt=""></div>
                    <div class="images-title">EOL</div>
                </div>
                <div onclick="window.open('https://www.fishbase.org/search.php', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/FishBase.png" alt=""></div>
                    <div class="images-title">FishBase</div>
                </div>
                <div onclick="window.open('https://www.iucnredlist.org/', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/IUCN.png" alt=""></div>
                    <div class="images-title">IUCN</div>
                </div>
                <div onclick="window.open(' https://www.ncei.noaa.gov/products/world-ocean-database', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/NORR.png" alt=""></div>
                    <div class="images-title">WOD</div>
                </div>
                <div onclick="window.open('https://oceanexplorer.noaa.gov/', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/OCEAN.png" alt=""></div>
                    <div class="images-title">NOAA</div>
                </div>
                <div onclick="window.open('https://www.sealifebase.ca', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/SeaLifeBase.png" alt=""></div>
                    <div class="images-title">SeaLifeBase</div>
                </div>
                <div onclick="window.open('https://www.marinespecies.org/', '_blank')" style="cursor: pointer;">
                    <div class="images"><img src="/images/DataBase/WORMS.png" alt=""></div>
                    <div class="images-title">WoRMS</div>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="recognitionModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <h2 class="result-title">海洋生物识别结果</h2>
        <div class="result-container" id="recognitionResult"></div>
    </div>
</div>

<script>
    function loadStatistics() {
        fetch('/api/statistics')
            .then(response => response.json())
            .then(data => {
                document.getElementById('classCount').textContent = data.classCount;
                document.getElementById('orderCount').textContent = data.orderCount;
                document.getElementById('familyCount').textContent = data.familyCount;
                document.getElementById('speciesCount').textContent = data.speciesCount;
                animateValue('classCount', 0, data.classCount, 800);
                animateValue('orderCount', 0, data.orderCount, 800);
                animateValue('familyCount', 0, data.familyCount, 800);
                animateValue('speciesCount', 0, data.speciesCount, 800);
            })
            .catch(error => console.error('Error loading statistics:', error));
    }

    function animateValue(id, start, end, duration) {
        const element = document.getElementById(id);
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            element.textContent = Math.floor(progress * (end - start) + start);
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }

    document.addEventListener('DOMContentLoaded', function() {
        loadStatistics();

        const customSelects = document.querySelectorAll('.custom-select');
        customSelects.forEach(select => {
            const header = select.querySelector('.select-header');
            const selectedValue = select.querySelector('.selected-value');
            const options = select.querySelectorAll('.option');
            const originalSelect = select.querySelector('.original-select');

            const initialOption = originalSelect.querySelector('option:checked') || originalSelect.querySelector('option');
            if (initialOption) {
                selectedValue.textContent = initialOption.textContent;
                originalSelect.value = initialOption.value;
                options[0].classList.add('selected');
            }

            options.forEach(option => {
                option.addEventListener('click', function() {
                    selectedValue.textContent = this.textContent;
                    originalSelect.value = this.dataset.value;
                    options.forEach(opt => opt.classList.remove('selected'));
                    this.classList.add('selected');
                    const event = new Event('change');
                    originalSelect.dispatchEvent(event);
                });
            });
        });

        const searchActionBtn = document.querySelector('.search-action');
        const fileInput = document.getElementById('fileInput');
        const uploadImageBox = document.querySelector('.uploadImage');
        const previewIcon = document.querySelector('.preview-icon');
        const fileNameSpan = document.querySelector('.file-name');
        const deleteBtn = document.querySelector('.chacha');
        let currentFile = null;

        searchActionBtn.addEventListener('click', function() {
            fileInput.click();
        });

        fileInput.addEventListener('change', function(e) {
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
                reader.onload = function(e) {
                    previewIcon.src = e.target.result;
                    uploadImageBox.style.display = 'flex';
                };
                reader.readAsDataURL(file);
            }
        });

        deleteBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            uploadImageBox.style.display = 'none';
            fileInput.value = '';
            currentFile = null;
        });

        const searchSubmitBtn = document.querySelector('.search-submit');
        const searchInput = document.querySelector('.search-input');
        const originalSelect = document.querySelector('.original-select');

        searchSubmitBtn.addEventListener('click', async function() {
            if (currentFile) {
                try {
                    uploadImageBox.innerHTML = '<div style="padding:10px;">识别中...</div>';
                    const formData = new FormData();
                    formData.append('image', currentFile);
                    const response = await fetch('/ai/recognize', {
                        method: 'POST',
                        body: formData
                    });
                    const data = await response.json();
                    if (data.code === 200 && data.data && data.data.data) {
                        showRecognitionResult(data.data.data);
                        resetUploadPreview();
                    } else {
                        throw new Error(data.message || '识别失败');
                    }
                } catch (error) {
                    console.error('识别失败:', error);
                    showErrorToast(`识别失败: ${error.message}`);
                    resetUploadPreview();
                }
            } else {
                const speciesName = searchInput.value.trim();
                const speciesClass = originalSelect.value;
                if (speciesName) {
                    window.location.href = '/SimplyQuery?name=' + encodeURIComponent(speciesName) + '&category=' + encodeURIComponent(speciesClass);
                } else {
                    alert('请输入物种名称或上传图片');
                }
            }
        });

        const modal = document.getElementById('recognitionModal');
        const closeBtn = document.querySelector('.close');
        closeBtn.onclick = function() { modal.style.display = "none"; }
        window.onclick = function(event) { if (event.target == modal) modal.style.display = "none"; }

        function showErrorToast(message) {
            const toast = document.createElement('div');
            toast.style.cssText = 'position:fixed;bottom:20px;right:20px;padding:10px 20px;background:#ff4444;color:white;border-radius:4px;box-shadow:0 2px 10px rgba(0,0,0,0.2);z-index:1000;animation:fadeIn 0.3s ease;';
            toast.innerHTML = message + '<span style="margin-left:10px;cursor:pointer;">×</span>';
            document.body.appendChild(toast);
            setTimeout(() => { toast.style.animation = 'fadeOut 0.3s ease'; setTimeout(() => toast.remove(), 300); }, 3000);
            toast.querySelector('span').addEventListener('click', () => { toast.style.animation = 'fadeOut 0.3s ease'; setTimeout(() => toast.remove(), 300); });
        }

        function resetUploadPreview() {
            fileInput.value = '';
            currentFile = null;
            uploadImageBox.innerHTML = `<img src="/images/index/picture.png" class="preview-icon" style="width:22px;height:22px;" alt=""><span class="file-name"></span><img src="/images/index/No.png" class="chacha" alt="删除">`;
            uploadImageBox.style.display = 'none';
            uploadImageBox.querySelector('.chacha').addEventListener('click', function(e) {
                e.stopPropagation();
                resetUploadPreview();
            });
        }

        function showRecognitionResult(result) {
            const resultContainer = document.getElementById('recognitionResult');
            resultContainer.innerHTML = `
                <div class="result-item"><span class="result-label">名称:</span><span class="result-value">${result.name}</span></div>
                <div class="result-item"><span class="result-label">纲:</span><span class="result-value">${result.animalClass}</span></div>
                <div class="result-item"><span class="result-label">目:</span><span class="result-value">${result.order}</span></div>
                <div class="result-item"><span class="result-label">科:</span><span class="result-value">${result.family}</span></div>
                ${result.imageUrl ? `<img src="${result.imageUrl}" class="result-image" alt="${result.name}">` : ''}
                <div class="result-description">${result.description || '暂无详细描述'}</div>
            `;
            modal.style.display = "block";
            resetUploadPreview();
        }
    });
</script>
</body>
</html>