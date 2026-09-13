<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%--
  公共导航栏片段（基于 Vue.js + Element UI）
  使用方式：<%@ include file="navbar.jsp" %>
  通过 request.getAttribute("activeMenu") 设置高亮项：index/classify/ai/show/defend/game
--%>
<div id="appNavbar" v-cloak>
  <el-menu mode="horizontal" :default-active="active" class="ocean-navbar"
           @select="handleSelect">
    <div class="navbar-brand">
      <img src="/images/newlogo.png" alt="logo" class="brand-logo">
      <div class="brand-title">
        <div class="brand-cn">海洋生物图鉴</div>
        <div class="brand-en">WHALEQUEST</div>
      </div>
    </div>
    <el-menu-item index="index" class="nav-item">首页</el-menu-item>
    <el-menu-item index="classify" class="nav-item">档案查询</el-menu-item>
    <el-menu-item index="ai" class="nav-item">AI助手</el-menu-item>
    <el-menu-item index="show" class="nav-item">生物图谱</el-menu-item>
    <el-menu-item index="defend" class="nav-item">保护专区</el-menu-item>
    <el-menu-item index="game" class="nav-item">科普游戏</el-menu-item>
    <div class="navbar-right">
      <span class="welcome-text">欢迎,{{userName}}！</span>
      <img src="/images/index/happy.png" alt="头像" class="user-avatar">
    </div>
  </el-menu>
</div>

<script>
  // 独立挂载导航栏 Vue 实例（页面可在 DOM ready 后挂载）
  (function () {
    function mountNavbar() {
      if (typeof Vue === 'undefined' || typeof ELEMENT === 'undefined') {
        setTimeout(mountNavbar, 50);
        return;
      }
      var active = '<%= request.getAttribute("activeMenu") != null ? request.getAttribute("activeMenu") : "index" %>';
      new Vue({
        el: '#appNavbar',
        data: { active: active, userName: '游客' },
        methods: {
          handleSelect: function (index) {
            var map = {
              index: '/index',
              classify: '/classfiyQuery',
              ai: '/aiRobot',
              show: '/show',
              defend: '/defendSea',
              game: '/playGame'
            };
            if (map[index]) window.location.href = map[index];
          }
        }
      });
    }
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', mountNavbar);
    } else {
      mountNavbar();
    }
  })();
</script>

<style>
  #appNavbar[v-cloak] { display: none; }
  .ocean-navbar.el-menu--horizontal {
    display: flex;
    align-items: center;
    flex-wrap: nowrap;
    background-color: rgba(255, 255, 255, 0.40);
    border-bottom: none;
    padding: 1.5vh 1vw;
    overflow-x: auto;
    scrollbar-width: none;
  }
  .ocean-navbar.el-menu--horizontal::-webkit-scrollbar { display: none; }
  .navbar-brand {
    display: flex;
    align-items: center;
    margin-left: 1.5vw;
    margin-right: 30px;
    flex-shrink: 0;
  }
  .brand-logo {
    width: 4vw;
    height: 4vw;
    min-width: 36px;
    min-height: 36px;
    border-radius: 50%;
  }
  .brand-title { margin-left: 1vw; display: flex; flex-direction: column; align-items: center; }
  .brand-cn {
    font-family: 'STXingkai', 'KaiTi', '楷体', 'LiSu', '隶书', cursive;
    font-size: 3.2vh;
    color: black;
    text-shadow: 3px 3px 5px rgba(139, 137, 137, 0.3);
    font-weight: 800;
    white-space: nowrap;
  }
  .brand-en {
    font-family: 'Courier New', Courier, monospace;
    font-size: 1.2vh;
    font-weight: 400;
    color: #333;
  }
  .ocean-navbar .nav-item.el-menu-item {
    height: 8vh;
    min-height: 40px;
    line-height: 8vh;
    font-size: 1.15vw;
    color: #fff;
    background-color: transparent !important;
    border-bottom: none;
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
    white-space: nowrap;
    padding: 0 1.2vw;
  }
  .ocean-navbar .nav-item.el-menu-item:hover,
  .ocean-navbar .nav-item.el-menu-item:focus {
    color: #ffd000 !important;
    background-color: transparent !important;
  }
  .ocean-navbar .nav-item.el-menu-item.is-active {
    color: #ffd000 !important;
    background-color: transparent !important;
    border-bottom: 0.4vh solid orange !important;
  }
  .navbar-right {
    margin-left: auto;
    display: flex;
    align-items: center;
    color: #fff;
    padding-right: 1vw;
    flex-shrink: 0;
  }
  .navbar-right .welcome-text { font-size: clamp(11px, 1.1vw, 14px); margin-right: 8px; white-space: nowrap; }
  .navbar-right .user-avatar { width: 4vh; height: 4vh; min-width: 28px; min-height: 28px; }
  @media (max-width: 768px) {
    .navbar-brand { margin-left: 8px; margin-right: 12px; }
    .brand-logo { width: 36px; height: 36px; }
    .brand-cn { font-size: 18px; }
    .brand-en { font-size: 9px; }
    .ocean-navbar .nav-item.el-menu-item {
      height: 40px; line-height: 40px; font-size: 13px; padding: 0 10px;
    }
    .navbar-right .welcome-text { font-size: 11px; }
    .navbar-right .user-avatar { width: 26px; height: 26px; }
  }
</style>
