<%--
  Created by IntelliJ IDEA.
  User: 30202
  Date: 2025/8/5
  Time: 10:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>海洋生物保护专区</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <!-- Vue 2 + Element UI CDN -->
    <link rel="stylesheet" href="https://unpkg.com/element-ui@2.15.14/lib/theme-chalk/index.css">
    <style>
        [v-cloak] { display: none; }
        body {
            background-image: url("/images/defend/background.png");
            background-size: cover;
            background-attachment: fixed;
            font-family: 'Microsoft YaHei', sans-serif;
            margin: 0;
            padding: 0;
            -webkit-tap-highlight-color: transparent;
        }

        .body {
            margin: 0;
            padding: 0;
            width: 100%;
            min-height: 100vh;
            min-height: 100dvh;
            display: flex;
            flex-direction: column;
        }

        /* 导航栏样式 */
        .navbar {
            display: flex;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.40);
            padding: 2vh 0;
            position: relative;
            z-index: 1000;
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
            width: 9vw;
            height: 8vh;
            font-size: 1.2vw;
            line-height: 1.2vw;
            font-family: 'Gill Sans', 'Gill SansMT', Calibri, 'Trebuchet MS', sans-serif;
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
            color: yellow;
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

        /* IUCN濒危物种展示区域样式 */
        .conservation-container {
            max-width: 1300px;
            margin: 30px auto;
            padding: 0 20px;
            flex: 1;
        }

        .conservation-header {
            text-align: center;
            margin-bottom: 30px;
            color: white;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }

        .conservation-header h1 {
            font-size: 3rem;
            margin-bottom: 10px;
        }

        .conservation-header p {
            font-size: 1.3rem;
            max-width: 860px;
            margin: 0 auto;
        }

        /* 物种分类筛选 */
        .species-filter {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 30px;
        }

        .filter-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 30px;
            background-color: rgba(255, 255, 255, 0.8);
            color: #333;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 16px;
            white-space: nowrap;
            user-select: none;
            -webkit-user-select: none;
            -webkit-tap-highlight-color: transparent;
        }

        .filter-btn:hover {
            background-color: #fff;
            transform: translateY(-2px);
        }

        .filter-btn:active {
            transform: scale(0.95);
        }

        .filter-btn.active {
            background-color: #e74c3c;
            color: white;
        }

        /* 物种卡片网格 */
        .species-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 25px;
            margin-bottom: 50px;
        }

        .species-card {
            background-color: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .species-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        }

        .species-image {
            width: 100%;
            height: 240px;
            object-fit: cover;
        }

        .species-content {
            padding: 20px;
        }

        .species-name {
            font-size: 1.5rem;
            margin: 0 0 10px;
            color: #2c3e50;
        }

        .species-scientific {
            font-style: italic;
            color: #7f8c8d;
            margin-bottom: 15px;
            display: block;
        }

        .species-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: bold;
            margin-bottom: 15px;
        }

        .status-cr {
            background-color: #e74c3c;
            color: white;
        }

        .status-en {
            background-color: #f39c12;
            color: white;
        }

        .status-vu {
            background-color: #f1c40f;
            color: #333;
        }

        .status-nt{
            background-color: #f4d766;
            color: #333;
        }

        .species-info {
            margin-bottom: 15px;
            line-height: 1.6;
        }

        .species-info p {
            margin: 5px 0;
        }

        .species-info strong {
            color: #2c3e50;
        }

        .flex{
            display: flex;
            justify-content: space-between;
        }

        .species-threats {
            width: 40%;
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 15px;
        }

        .species-threats h4 {
            margin-top: 0;
            color: #e74c3c;
        }

        .threats-list {
            padding-left: 20px;
        }

        .species-conservation {
            width: 40%;
            background-color: #e8f4fc;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 15px;
        }

        .species-conservation h4 {
            margin-top: 0;
            color: #3498db;
        }

        .conservation-list {
            padding-left: 20px;
        }

        /* ==================== 移动端适配 ==================== */
        @media (max-width: 768px) {
            /* 导航栏横向滚动 */
            .navbar {
                flex-wrap: nowrap;
                overflow-x: auto;
                overflow-y: hidden;
                -webkit-overflow-scrolling: touch;
                scrollbar-width: none;
                -ms-overflow-style: none;
                padding: 10px 5px;
                gap: 0;
                white-space: nowrap;
            }

            .navbar::-webkit-scrollbar {
                display: none;
                width: 0;
                height: 0;
            }

            .library-name {
                margin-left: 8px;
                flex-shrink: 0;
            }

            .library-name img {
                width: 32px !important;
                height: 32px !important;
            }

            .library-title div:first-child {
                font-size: 16px !important;
            }

            .library-title div:last-child {
                font-size: 8px !important;
            }

            .left-nav {
                margin-left: 5px !important;
                display: flex;
                flex-wrap: nowrap;
                align-items: center;
                gap: 4px;
                flex-shrink: 0;
            }

            .dropdown .dropbtn {
                width: auto;
                min-width: 42px;
                height: auto;
                padding: 8px 7px;
                font-size: 12px;
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
                padding-right: 8px;
                font-size: 11px;
                white-space: nowrap;
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .right img {
                width: 28px;
                height: 28px;
                margin: 0;
            }

            /* 容器与标题 */
            .conservation-container {
                padding: 0 12px;
                margin: 20px auto;
            }

            .conservation-header h1 {
                font-size: 2rem;
                margin-bottom: 8px;
            }

            .conservation-header p {
                font-size: 1rem;
                line-height: 1.5;
            }

            /* 筛选按钮 */
            .species-filter {
                gap: 8px;
                margin-bottom: 20px;
            }

            .filter-btn {
                padding: 8px 16px;
                font-size: 14px;
                border-radius: 25px;
            }

            /* 物种卡片网格改为单列 */
            .species-grid {
                grid-template-columns: 1fr;
                gap: 20px;
                margin-bottom: 30px;
            }

            .species-image {
                height: 180px;
            }

            .species-content {
                padding: 15px;
            }

            .species-name {
                font-size: 1.3rem;
                margin-bottom: 6px;
            }

            /* 将卡片内并排的威胁和保护措施改为上下堆叠 */
            .flex {
                flex-direction: column;
            }

            .species-threats,
            .species-conservation {
                width: 100%;
                margin-bottom: 10px;
                box-sizing: border-box;
            }

            .species-info p {
                font-size: 14px;
            }

            .species-scientific {
                font-size: 14px;
                margin-bottom: 10px;
            }

            .species-threats h4,
            .species-conservation h4 {
                font-size: 15px;
            }

            .threats-list li,
            .conservation-list li {
                font-size: 13px;
            }

            .species-status {
                font-size: 13px;
                padding: 4px 8px;
            }
        }

        /* 更小屏幕优化 */
        @media (max-width: 400px) {
            .dropdown .dropbtn {
                font-size: 10px;
                padding: 6px 4px;
                min-width: 34px;
            }

            .library-name img {
                width: 28px !important;
                height: 28px !important;
            }

            .library-title div:first-child {
                font-size: 14px !important;
            }

            .right {
                font-size: 10px;
            }

            .right img {
                width: 24px;
                height: 24px;
            }

            .conservation-header h1 {
                font-size: 1.7rem;
            }

            .conservation-header p {
                font-size: 0.9rem;
            }

            .filter-btn {
                padding: 6px 12px;
                font-size: 12px;
            }

            .species-image {
                height: 150px;
            }

            .species-name {
                font-size: 1.1rem;
            }
        }
    </style>
</head>

<body>
<div class="body">
    <%@ include file="navbar.jsp" %>

    <!-- IUCN濒危物种展示区域 -->
    <div id="appDefend" class="conservation-container" v-cloak>
        <div class="conservation-header">
            <h1><i class="fas fa-exclamation-triangle"></i> IUCN濒危海洋物种</h1>
            <p>根据国际自然保护联盟(IUCN)红色名录，这些海洋物种正面临不同程度的灭绝威胁，需要我们共同保护</p>
        </div>

        <div class="species-filter">
            <el-button v-for="btn in filters" :key="btn.value"
                       :type="activeFilter === btn.value ? 'danger' : 'default'"
                       class="filter-btn"
                       :class="{ active: activeFilter === btn.value }"
                       @click="filterSpecies(btn.value)">
                {{ btn.label }}
            </el-button>
        </div>

        <div class="species-grid">
            <div v-for="species in filteredSpecies" :key="species.id" class="species-card">
                <img :src="species.image" :alt="species.name" class="species-image"
                     @error="onImageError($event)">
                <div class="species-content">
                    <div class="flex">
                        <h3 class="species-name">{{ species.name }}</h3>
                        <el-tag :type="statusType(species.status)" effect="dark" size="small">
                            {{ statusText(species.status) }}
                        </el-tag>
                    </div>
                    <span class="species-scientific">{{ species.scientific }}</span>
                    <div class="species-info">
                        <p><strong>现存数量:</strong> {{ species.population }}</p>
                        <p><strong>主要分布:</strong> {{ species.region }}</p>
                        <p>{{ species.description }}</p>
                    </div>
                    <div class="flex">
                        <div class="species-threats">
                            <h4><i class="fas fa-exclamation-circle"></i> 主要威胁</h4>
                            <ul class="threats-list">
                                <li v-for="(threat, i) in species.threats" :key="i">{{ threat }}</li>
                            </ul>
                        </div>
                        <div class="species-conservation">
                            <h4><i class="fas fa-shield-alt"></i> 保护措施</h4>
                            <ul class="conservation-list">
                                <li v-for="(action, i) in species.conservation" :key="i">{{ action }}</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <el-empty v-if="filteredSpecies.length === 0" description="暂无符合条件的物种"></el-empty>
    </div>
</div>
<script src="https://unpkg.com/vue@2.7.16/dist/vue.js"></script>
<script src="https://unpkg.com/element-ui@2.15.14/lib/index.js"></script>
<script>
    // IUCN濒危海洋物种数据
    const endangeredSpecies = [
        {
            id: 1,
            name: "加湾鼠海豚",
            scientific: "Phocoena sinus",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.dbc07d06cc50b811378b7b6c02762eda?rik=F7i1pKNkW7nJ8A&riu=http%3a%2f%2fimg1.bala.cc%2fallimg%2f2312%2f234PT548-0.jpg&ehk=4XpTDfsUVcmy0ZxgybDIBZov0GNYFpfyUvIOBT7lw8o%3d&risl=&pid=ImgRaw&r=0",
            status: "CR",
            category: ["mammals"],
            population: "不足20头",
            region: "墨西哥加利福尼亚湾北部",
            description: "加湾鼠海豚是世界上最濒危的海洋哺乳动物，体型最小，仅存于墨西哥加利福尼亚湾北部。",
            threats: ["刺网捕捞", "栖息地退化", "近亲繁殖", "污染物积累"],
            conservation: ["建立永久禁渔区", "加强巡逻执法", "推广替代渔具", "开展人工繁殖计划"]
        },
        {
            id: 2,
            name: "北大西洋露脊鲸",
            scientific: "Eubalaena glacialis",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.c5376d9a27d8c9efdc9fd2799ef6b336?rik=XGVD8fJTWB6n3A&riu=http%3a%2f%2fwww.xlgtx.com%2fuploads%2fallimg%2f230108%2f2053131548-2.jpg&ehk=sRxZmDYC6uuyaYMZXBjpeAwZQyPaAVwtYXWz53SU7Do%3d&risl=&pid=ImgRaw&r=0",
            status: "CR",
            category: ["mammals"],
            population: "约400头",
            region: "北大西洋西部",
            description: "北大西洋露脊鲸游动缓慢，常在海面附近活动，因富含油脂而成为捕鲸时代的主要目标。",
            threats: ["船只撞击", "渔网缠绕", "海洋噪音", "气候变化"],
            conservation: ["船只限速区", "渔具改良", "洄游路线保护", "个体识别研究"]
        },
        {
            id: 3,
            name: "蓝鳍金枪鱼",
            scientific: "Thunnus thynnus",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.f7009d706918ac3f38be5ff8c9fb46b7?rik=hWvoy4vVKGLtbQ&riu=http%3a%2f%2fpic.baike.soso.com%2fp%2f20140709%2f20140709162756-1432444454.jpg&ehk=OF44eeBOzA6Y4E0xklmduvWqKRtSzz%2bFhB9d8riK23o%3d&risl=&pid=ImgRaw&r=0&sres=1&sresct=1",
            status: "EN",
            category: ["fish"],
            population: "持续下降",
            region: "全球温带海域",
            description: "蓝鳍金枪鱼是海洋中游速最快的鱼类之一，因肉质鲜美而面临过度捕捞。",
            threats: ["过度捕捞", "非法捕捞", "栖息地破坏"],
            conservation: ["捕捞配额限制", "养殖技术研发", "保护区设立"]
        },
        {
            id: 4,
            name: "玳瑁",
            scientific: "Eretmochelys imbricata",
            image: "https://ts1.tc.mm.bing.net/th/id/OIP-C.qSu4n1GkZ5bM9zkXye4PswHaE8?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "CR",
            category: ["reptiles"],
            population: "未知",
            region: "热带海域",
            description: "玳瑁以其美丽的壳而闻名，是珊瑚礁生态系统中的重要物种。",
            threats: ["非法贸易", "栖息地破坏", "气候变化", "塑料污染"],
            conservation: ["栖息地保护", "非法贸易打击", "人工孵化放流"]
        },
        {
            id: 5,
            name: "大白鲨",
            scientific: "Carcharodon carcharias",
            image: "https://p1.ssl.qhmsg.com/t0169339a83536fcc2c.jpg",
            status: "VU",
            category: ["fish"],
            population: "持续减少",
            region: "全球温带海域",
            description: "大白鲨是海洋顶级捕食者，对维持海洋生态系统平衡至关重要。",
            threats: ["鱼翅贸易", "兼捕", "海洋污染", "气候变化"],
            conservation: ["国际保护协议", "禁止鱼翅贸易", "生态旅游开发"]
        },
        {
            id: 6,
            name: "海马",
            scientific: "Hippocampus spp.",
            image: "/images/defend/haima.jpg",
            status: "VU",
            category: ["fish"],
            population: "快速下降",
            region: "全球热带海域",
            description: "海马是海洋中最独特的鱼类之一，雄性负责孕育后代。",
            threats: ["传统医药", "观赏贸易", "栖息地丧失", "兼捕"],
            conservation: ["人工养殖推广", "栖息地恢复", "贸易管制"]
        },
        {
            id: 7,
            name: "蓝鲸",
            scientific: "Balaenoptera musculus",
            image: "https://so1.360tres.com/t0177c81691ec450afb.jpg",
            status: "EN",
            category: ["mammals"],
            population: "10,000-25,000头",
            region: "全球海洋",
            description: "蓝鲸是地球上已知最大的动物，体长可达30米，重达200吨。",
            threats: ["船只撞击", "气候变化", "海洋噪音", "污染"],
            conservation: ["航运路线调整", "保护区设立", "科研监测"]
        },
        {
            id: 8,
            name: "棱皮龟",
            scientific: "Dermochelys coriacea",
            image: "https://bwg.gdou.edu.cn/__local/9/A2/C8/3F68A70B715C95B50360DF9C06D_26427C0C_E37F.jpg?e=.jpg",
            status: "VU",
            category: ["reptiles"],
            population: "持续下降",
            region: "热带和温带海域",
            description: "棱皮龟是现存最大的海龟，没有硬壳而是覆盖着革质皮肤。",
            threats: ["塑料污染", "非法捕捞", "栖息地丧失", "气候变化"],
            conservation: ["海滩保护", "减少塑料污染", "人工孵化放流"]
        },
        {
            id: 9,
            name: "儒艮",
            scientific: "Dugong dugon",
            image: "https://ts3.tc.mm.bing.net/th/id/OIP-C.ZXai9FbTmXz-v0AVfwTZlQHaEv?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "VU",
            category: ["mammals"],
            population: "持续减少",
            region: "印度洋和西太平洋",
            description: "儒艮是海洋中唯一的草食性哺乳动物，被认为是美人鱼传说的来源。",
            threats: ["栖息地破坏", "非法捕捞", "船只撞击", "污染"],
            conservation: ["海草床保护", "渔业管理", "生态旅游"]
        },
        {
            id: 10,
            name: "珊瑚",
            scientific: "Scleractinia",
            image: "https://p1.ssl.qhmsg.com/t01abf663441bb42f6d.jpg",
            status: "CR",
            category: ["invertebrates"],
            population: "全球衰退",
            region: "热带海域",
            description: "珊瑚是海洋生态系统的基础，为25%的海洋生物提供栖息地。",
            threats: ["海洋酸化", "水温升高", "污染", "过度捕捞"],
            conservation: ["减少碳排放", "珊瑚礁保护", "人工珊瑚培育"]
        },
        {
            id: 11,
            name: "鲸鲨",
            scientific: "Rhincodon typus",
            image: "https://ts3.tc.mm.bing.net/th/id/OIP-C.ZntsxnPXItCZE0RKCa2CUwHaEr?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "EN",
            category: ["fish"],
            population: "持续减少",
            region: "全球热带海域",
            description: "鲸鲨是现存最大的鱼类，体长可达18米，性情温和以浮游生物为食。",
            threats: ["渔业兼捕", "旅游干扰", "船只撞击", "污染"],
            conservation: ["保护区设立", "生态旅游规范", "科研监测"]
        },
        {
            id: 12,
            name: "海獭",
            scientific: "Enhydra lutris",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.cd7b25c808506a8b7a33a5e3650d881d?rik=p9OERykQ7u%2fyEQ&riu=http%3a%2f%2f5b0988e595225.cdn.sohucs.com%2fimages%2f20190912%2f33e19a38ecff4910a50ef61fd628aaec.jpeg&ehk=gxz5v8zfJmNracAC83sYCpr2DVr0zIsSUKokwx0K1ec%3d&risl=&pid=ImgRaw&r=0",
            status: "EN",
            category: ["mammals"],
            population: "约3,000头",
            region: "北太平洋",
            description: "海獭是海洋哺乳动物中使用工具的代表，对海藻林生态系统至关重要。",
            threats: ["石油泄漏", "栖息地丧失", "非法捕捞", "污染"],
            conservation: ["石油运输监管", "栖息地保护", "人工繁育"]
        },
        {
            id: 13,
            name: "中华白海豚",
            scientific: "Sousa chinensis",
            image: "https://tr-osdcp.qunarzz.com/tr-osd-tr-space/img/bc1b85aaea2b7d96f08bd267af46e1de.jpg_r_1360x1360x95_de7fcc9e.jpg",
            status: "VU",
            category: ["mammals"],
            population: "约2,000头",
            region: "中国东南沿海",
            description: "中华白海豚因其粉红色外表被称为'海上大熊猫'，是近岸生态系统指示物种。",
            threats: ["填海造地", "船只撞击", "渔业冲突", "污染"],
            conservation: ["建立保护区", "航运限速", "生态补偿"]
        },
        {
            id: 14,
            name: "地中海僧海豹",
            scientific: "Monachus monachus",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.1629acf152040756543446493e105dff?rik=bZapA7C8ooVDxg&riu=http%3a%2f%2fimg0.dili360.com%2fga%2fM01%2f02%2fB5%2fwKgBzFQ27TKAMKbuAAWfVrstjUk751.jpg%40!rw9&ehk=F3IznTQw46VgMsqFutP7vjcpJ1AsJ5km4FWm9Um0Mng%3d&risl=&pid=ImgRaw&r=0",
            status: "EN",
            category: ["mammals"],
            population: "约700头",
            region: "地中海",
            description: "地中海僧海豹是世界上最濒危的海豹之一，喜欢栖息在海岸洞穴中。",
            threats: ["栖息地丧失", "过度捕捞", "旅游干扰", "污染"],
            conservation: ["海岸保护", "渔业管理", "公众教育"]
        },
        {
            id: 15,
            name: "姥鲨",
            scientific: "Cetorhinus maximus",
            image: "https://omo-oss-image.thefastimg.com/portal-saas/new2022081810104381564/cms/image/a44a89eb-37c8-447e-a343-2ac32c1af5f1.jpg",
            status: "EN",
            category: ["fish"],
            population: "持续减少",
            region: "全球温带海域",
            description: "姥鲨是第二大鱼类，以浮游生物为食，常在海面缓慢游动。",
            threats: ["鱼鳍捕捞", "船只撞击", "海洋污染"],
            conservation: ["国际保护协议", "禁止鱼鳍贸易", "迁徙路线研究"]
        },
        {
            id: 16,
            name: "绿海龟",
            scientific: "Chelonia mydas",
            image: "https://ts2.tc.mm.bing.net/th/id/OIP-C.r7UCqaLuAmMDIWqTSXiHRwHaFS?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "EN",
            category: ["reptiles"],
            population: "持续下降",
            region: "全球热带海域",
            description: "绿海龟是唯一以海草为主食的海龟，成年后背部呈橄榄绿色。",
            threats: ["海滩开发", "非法捕捞", "塑料污染", "气候变化"],
            conservation: ["海滩保护", "人工孵化", "减少塑料使用"]
        },
        {
            id: 17,
            name: "小头鼠海豚",
            scientific: "Phocoena phocoena",
            image: "https://tse4-mm.cn.bing.net/th/id/OIP-C.jpPprmyUwZrE2j76c-NrLwHaFW?w=219&h=180&c=7&r=0&o=7&dpr=1.4&pid=1.7&rm=3",
            status: "VU",
            category: ["mammals"],
            population: "持续减少",
            region: "北大西洋",
            description: "小头鼠海豚是北半球最常见的鲸类之一，但种群数量正快速下降。",
            threats: ["刺网捕捞", "海洋噪音", "污染", "猎物减少"],
            conservation: ["渔具改良", "声呐管制", "栖息地保护"]
        },
        {
            id: 18,
            name: "红珊瑚",
            scientific: "Corallium rubrum",
            image: "/images/defend/hot.jpg",
            status: "CR",
            category: ["invertebrates"],
            population: "急剧减少",
            region: "地中海",
            description: "红珊瑚生长极为缓慢，因其珍贵被用于珠宝制作已有数千年历史。",
            threats: ["过度采集", "海洋酸化", "底拖网捕捞"],
            conservation: ["采集禁令", "人工培育", "栖息地保护"]
        },
        {
            id: 19,
            name: "锯鳐",
            scientific: "Pristis spp.",
            image: "https://k.sinaimg.cn/www/dy/slidenews/5_img/2015_16/453_64664_651004.jpg/w640slw.jpg",
            status: "CR",
            category: ["fish"],
            population: "极度濒危",
            region: "热带海域",
            description: "锯鳐以其独特的锯状吻部闻名，是底栖生态系统的关键物种。",
            threats: ["兼捕", "栖息地丧失", "非法贸易"],
            conservation: ["禁止捕捞", "栖息地恢复", "人工繁殖"]
        },
        {
            id: 20,
            name: "北极露脊鲸",
            scientific: "Balaena mysticetus",
            image: "https://p1.ssl.qhmsg.com/t0163b7fa1a2fb1747e.jpg",
            status: "EN",
            category: ["mammals"],
            population: "约10,000头",
            region: "北极海域",
            description: "北极露脊鲸寿命可达200年，拥有所有动物中最厚的脂肪层。",
            threats: ["气候变化", "航运增加", "石油开采"],
            conservation: ["航运管制", "石油开采限制", "传统捕鲸管理"]
        },
        {
            id: 21,
            name: "黄唇鱼",
            scientific: "Bahaba taipingensis",
            image: "/images/defend/yellow.png",
            status: "CR",
            category: ["fish"],
            population: "极度稀少",
            region: "中国南海",
            description: "黄唇鱼因其鱼鳔价值极高被称为'海上黄金'，面临严重过度捕捞。",
            threats: ["过度捕捞", "栖息地破坏", "非法贸易"],
            conservation: ["全面禁捕", "人工繁殖", "栖息地保护"]
        },
        {
            id: 22,
            name: "黑脚企鹅",
            scientific: "Spheniscus demersus",
            image: "/images/defend/black.jpg",
            status: "EN",
            category: ["birds"],
            population: "约50,000只",
            region: "非洲南部沿海",
            description: "黑脚企鹅是唯一在非洲繁殖的企鹅，数量在过去百年下降了90%。",
            threats: ["石油泄漏", "过度捕捞", "气候变化"],
            conservation: ["石油运输监管", "渔业管理", "人工巢穴"]
        },
        {
            id: 23,
            name: "海天使",
            scientific: "Clione limacina",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.8669e69bfd958fd90f7d6dab85d95f80?rik=v7KiIQ52V6QPbw&riu=http%3a%2f%2fn.sinaimg.cn%2fsinakd20210501ac%2f409%2fw750h459%2f20210501%2f9ebc-kpptear7989052.jpg&ehk=UFgN%2fE8SgUyZVBf9z3hndDbdFVQGaCytTSr%2bQmTA7kc%3d&risl=&pid=ImgRaw&r=0",
            status: "VU",
            category: ["invertebrates"],
            population: "快速减少",
            region: "北极海域",
            description: "海天使是一种小型浮游软体动物，对海洋酸化极为敏感。",
            threats: ["海洋酸化", "水温升高", "食物链变化"],
            conservation: ["减少碳排放", "极地保护", "生态监测"]
        },
        {
            id: 24,
            name: "蓝环章鱼",
            scientific: "Hapalochlaena spp.",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.3e04fd19a9a0f9d17c189fbda9d27e93?rik=Vc1VFaGUQ5zl6g&riu=http%3a%2f%2fwww.kudiaoyu.com%2fuploadfile%2f2021%2f1130%2f20211130010354712.jpg&ehk=J58OjLDCZ2bL16Oik%2boIlbp0wBSYGFwXl4f9W0gdKvo%3d&risl=&pid=ImgRaw&r=0",
            status: "NT",
            category: ["invertebrates"],
            population: "未知",
            region: "太平洋和印度洋",
            description: "蓝环章鱼是世界上最毒的海洋生物之一，受珊瑚礁退化威胁。",
            threats: ["栖息地丧失", "海洋污染", "非法采集"],
            conservation: ["珊瑚礁保护", "贸易管制", "公众教育"]
        },
        {
            id: 25,
            name: "海象",
            scientific: "Odobenus rosmarus",
            image: "https://ts4.tc.mm.bing.net/th/id/OIP-C.n_a8rICuIxAFYuxn_LEcqwHaFj?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "VU",
            category: ["mammals"],
            population: "持续减少",
            region: "北极海域",
            description: "海象依赖海冰生存，以其长牙和庞大的体型闻名。",
            threats: ["海冰减少", "石油开发", "航运干扰"],
            conservation: ["海冰保护", "航运管制", "传统狩猎管理"]
        },
        {
            id: 26,
            name: "砗磲",
            scientific: "Tridacna spp.",
            image: "https://ts2.tc.mm.bing.net/th/id/OIP-C.79Kdr5zeJLN9FhMVQbpxogHaFj?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "VU",
            category: ["invertebrates"],
            population: "急剧减少",
            region: "印度洋-太平洋",
            description: "砗磲是最大的双壳类动物，对珊瑚礁生态系统至关重要。",
            threats: ["过度采集", "栖息地破坏", "气候变化"],
            conservation: ["采集禁令", "人工繁殖", "珊瑚礁保护"]
        },
        {
            id: 27,
            name: "海牛",
            scientific: "Trichechus manatus",
            image: "https://ts1.tc.mm.bing.net/th/id/OIP-C.es_qWcK75DvJ0YeMzmhMRQHaFj?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "VU",
            category: ["mammals"],
            population: "约13,000头",
            region: "加勒比海和西非",
            description: "海牛行动缓慢，常因船只螺旋桨受伤，被称为'海洋奶牛'。",
            threats: ["船只撞击", "栖息地丧失", "污染"],
            conservation: ["船只限速", "水道保护", "救助康复"]
        },
        {
            id: 28,
            name: "帝企鹅",
            scientific: "Aptenodytes forsteri",
            image: "https://ts4.tc.mm.bing.net/th/id/OIP-C.lUGv4qp4aBX-sgu9uCcDPAHaE2?rs=1&pid=ImgDetMain&o=7&rm=3",
            status: "NT",
            category: ["birds"],
            population: "约60万对",
            region: "南极洲",
            description: "帝企鹅是最大的企鹅物种，以极端环境下的繁殖行为闻名。",
            threats: ["气候变化", "渔业影响", "旅游干扰"],
            conservation: ["南极保护", "渔业管理", "旅游限制"]
        },
        {
            id: 29,
            name: "海龙",
            scientific: "Phyllopteryx spp.",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.ee2ebd6719ba8ab595da17b2fe80b127?rik=2PZAG5GwQ1mV4w&riu=http%3a%2f%2fwww.qdaqua.com%2fneditor%2fuploadfile%2fimg%2f20211108160738778.png&ehk=Uc%2fSSc%2bSSeIpUYxBrsqVtCe%2fiOLNEfnD4%2fQihFHljY8%3d&risl=&pid=ImgRaw&r=0",
            status: "NT",
            category: ["fish"],
            population: "持续减少",
            region: "澳大利亚南部",
            description: "海龙是海马的近亲，拥有精美的伪装能力，深受潜水者喜爱。",
            threats: ["非法采集", "栖息地破坏", "气候变化"],
            conservation: ["采集禁令", "栖息地保护", "人工繁殖"]
        },
        {
            id: 30,
            name: "长尾鲨",
            scientific: "Alopias spp.",
            image: "https://ts1.tc.mm.bing.net/th/id/R-C.ed14dcc8ba278fbaad9dada3723f4fce?rik=cwK6nKUpJslDgg&riu=http%3a%2f%2fwww.tanmizhi.com%2fimg%2fallimg%2f07%2f23-200F10GGY10.jpg&ehk=bTudUjSpYqo8xUBJcvzKBzLOyYH0tkPFSIJ9s8BmCAc%3d&risl=&pid=ImgRaw&r=0&sres=1&sresct=1",
            status: "VU",
            category: ["fish"],
            population: "持续减少",
            region: "全球温带和热带海域",
            description: "长尾鲨以其超长的尾鳍闻名，可用来击晕猎物。",
            threats: ["鱼鳍贸易", "兼捕", "栖息地退化"],
            conservation: ["禁止鱼鳍贸易", "渔具改良", "保护区设立"]
        }
    ];

    // 渲染物种卡片 - 已迁移至 Vue 实例的 v-for
    // 筛选物种 - 已迁移至 Vue 实例的 filterSpecies 方法

    new Vue({
        el: '#appDefend',
        data: {
            activeFilter: 'all',
            filters: [
                { label: '全部物种', value: 'all' },
                { label: '极危(CR)', value: 'cr' },
                { label: '濒危(EN)', value: 'en' },
                { label: '易危(VU)', value: 'vu' },
                { label: '近危(NT)', value: 'nt' },
                { label: '海洋哺乳类', value: 'mammals' },
                { label: '鱼类', value: 'fish' },
                { label: '爬行类', value: 'reptiles' },
                { label: '无脊椎类', value: 'invertebrates' }
            ],
            species: endangeredSpecies
        },
        computed: {
            filteredSpecies: function () {
                var cat = this.activeFilter;
                if (cat === 'all') return this.species;
                if (['cr', 'en', 'vu', 'nt'].indexOf(cat) > -1) {
                    return this.species.filter(function (s) {
                        return s.status.toLowerCase() === cat;
                    });
                }
                return this.species.filter(function (s) {
                    return s.category.indexOf(cat) > -1;
                });
            }
        },
        methods: {
            filterSpecies: function (category) {
                this.activeFilter = category;
            },
            statusText: function (status) {
                return { CR: '极危(CR)', EN: '濒危(EN)', VU: '易危(VU)', NT: '近危(NT)' }[status] || status;
            },
            statusType: function (status) {
                return { CR: 'danger', EN: 'warning', VU: 'warning', NT: 'info' }[status] || 'info';
            },
            onImageError: function (e) {
                e.target.src = '/images/default-species.png';
            }
        }
    });
</script>
</body>

</html>