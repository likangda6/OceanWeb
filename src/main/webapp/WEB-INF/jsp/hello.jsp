<%--
  Created by IntelliJ IDEA.
  User: 30202
  Date: 2025/7/15
  Time: 22:19
  To change this template use File | Settings and File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>海洋生物图鉴</title>
    <!-- Vue 2 + Element UI CDN -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui@2.15.14/lib/theme-chalk/index.css">
    <style>
        @font-face {
            font-family: 'ZCOOL KuaiLe';
            src: url('https://fonts.googleapis.com/css2?family=ZCOOL+KuaiLe&display=swap');
        }

        [v-cloak] { display: none; }

        body {
            padding: 0;
            margin: 0;
            min-height: 100vh;
            min-height: 100dvh;
            background-image: url('/images/welcome/666.gif');
            background-size: cover;
            background-position: center center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-color: #000;
            -webkit-tap-highlight-color: transparent;
        }

        .header {
            width: 100%;
            height: 13vh;
            background-color: rgba(255, 255, 255, 0.30);
            display: flex;
            justify-content: center;
            justify-items: center;
            position: relative;
            padding-bottom: 5px;
        }

        .library-name {
            position: absolute;
            left: 4.2vw;
            top: 1vh;
            display: flex;
            justify-content: center;
            align-items: center;
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

        .poem {
            position: absolute;
            text-align: center;
            right: 1vw;
            top: 4.5vh;
            font-size: 1.5vw;
            font-family: "STXingkai", "KaiTi", "楷体", "LiSu", "隶书", cursive;
            font-size: 2.2rem;
            text-align: center;
            letter-spacing: 0.5rem;
            line-height: 1.8;
            color: rgb(5, 121, 184);
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
            padding: 20px;
        }

        .center-body {
            margin: 20vh auto;
            width: 80vw;
            height: 40vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .Chinese {
            font-family: 'Times New Roman', Times, serif;
            font-weight: 800;
            color: rgba(4, 108, 163, 0.8);
            text-shadow: 3px 3px 5px rgba(0, 0, 0, 0.3);
            font-size: 4.3rem;
            display: flex;
            align-items: center;
        }

        .English {
            font-family: 'Montserrat', "Helvetica Neue", sans-serif;
            font-size: 1.8rem;
            color: rgb(3, 95, 144);
            font-weight: 300;
        }

        .bottom-button { margin-top: 5vh; }

        .start-button {
            width: 30vw;
            height: 15vh;
            border: none;
            border-radius: 30px;
            font-size: 26px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: rgb(5, 121, 184);
            background-image: url('/images/welcome/yyy.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
        }

        .start-button:hover { transform: translateY(-5px); }
        .start-button:active { transform: translateX(5vw); }

        .start-button .arrow {
            width: 42px;
            height: 42px;
            margin-left: 10px;
            background-color: white;
            border-radius: 50%;
        }

        .img1 {
            width: 18vw;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            margin: 0;
            max-height: 100vh;
        }

        /* ==================== 移动端适配 ==================== */
        @media (max-width: 768px) {
            .header { height: auto; padding: 15px 10px; flex-wrap: wrap; }
            .library-name { position: static; margin-bottom: 10px; width: 100%; justify-content: flex-start; }
            .library-name img { width: 50px !important; height: 50px !important; }
            .library-title div:first-child { font-size: 28px !important; }
            .library-title div:last-child { font-size: 12px !important; }
            .poem {
                position: static; font-size: 1.4rem; letter-spacing: 0.2rem;
                padding: 10px 5px; margin: 5px 0; text-align: center; width: 100%;
            }
            .center-body { margin: 10vh auto; width: 90vw; height: auto; }
            .Chinese { font-size: 2.8rem; flex-wrap: wrap; justify-content: center; text-align: center; }
            .img1 { width: 40vw; margin: 5px 0; }
            .English { font-size: 1.1rem; text-align: center; margin: 10px 0; }
            .start-button {
                width: 70vw; height: auto; min-height: 70px; margin-top: 25px; border-radius: 20px;
            }
            .start-button .arrow { width: 32px; height: 32px; margin-left: 8px; }
            .start-button:active { transform: translateX(10vw); }
        }

        @media (max-width: 480px) {
            .library-name img { width: 40px !important; height: 40px !important; }
            .library-title div:first-child { font-size: 22px !important; }
            .library-title div:last-child { font-size: 10px !important; }
            .poem { font-size: 1.1rem; letter-spacing: 0.15rem; }
            .Chinese { font-size: 2.2rem; }
            .English { font-size: 0.9rem; }
            .start-button { width: 85vw; min-height: 60px; font-size: 18px; }
            .start-button .arrow { width: 28px; height: 28px; }
            .img1 { width: 35vw; }
        }
    </style>
</head>

<body>
<div id="app" v-cloak>
    <div class="header">
        <div class="library-name">
            <div><img style="width: 7vw;height: 7vw;border-radius: 50%;" src="/images/newlogo.png" alt=""></div>
            <div class="library-title">
                <div style="font-size: 4.5vh; font-family: 'STXingkai', 'KaiTi', '楷体', 'LiSu', '隶书', cursive;">
                    海洋生物图鉴
                </div>
                <div style="font-size: 1.6vh; font-family: 'Courier New', Courier, monospace; font-weight: 400;">
                    WHALEQUEST: MARINE BIO EXPLORER
                </div>
            </div>
        </div>
        <div class="poem">
            <div>亿万鳞光浮宙始，一泓咸泪孕生灵。</div>
        </div>
    </div>
    <div class="center-body">
        <div class="Chinese">欢迎来到<img class="img1" src="/images/welcome/newTitle.png" alt="">生物图鉴</div>
        <div class="English">WELCOME TO WHALEQUEST: MARINE BIO EXPLORER</div>
        <div class="bottom-button">
            <el-button class="start-button"
                       @click="enterIndex"
                       @mouseenter.native="onHover = true"
                       @mouseleave.native="onHover = false">
                立即体验
                <img class="arrow" src="/images/welcome/right.png" alt="">
            </el-button>
        </div>
    </div>
</div>

<script src="https://unpkg.com/vue@2.7.16/dist/vue.js"></script>
<script src="https://unpkg.com/element-ui@2.15.14/lib/index.js"></script>
<script>
    new Vue({
        el: '#app',
        data: { onHover: false },
        mounted: function () {
            // 进入页面时使用 Element UI 通知提示欢迎
            this.$notify({
                title: '欢迎',
                message: '探索海洋生物的奇妙世界',
                type: 'success',
                duration: 3000,
                position: 'top-right'
            });
        },
        methods: {
            enterIndex: function () {
                this.$message({ message: '正在进入首页...', type: 'info', duration: 800 });
                var ctx = '<%= request.getContextPath() %>';
                setTimeout(function () { window.location.href = ctx + '/index'; }, 600);
            }
        }
    });
</script>
</body>
</html>
