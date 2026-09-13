<template>
  <div class="ocean-navbar-wrap">
    <el-menu mode="horizontal" :default-active="active" class="ocean-navbar" @select="handleSelect">
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
      <el-menu-item index="videoList" class="nav-item">科普点播</el-menu-item>
      <el-submenu v-if="isAdmin" index="admin-menu" class="nav-item">
        <template slot="title"><i class="el-icon-s-tools"></i> 管理后台</template>
        <el-menu-item index="dashboard" class="nav-subitem"><i class="el-icon-monitor"></i> 仪表盘</el-menu-item>
        <el-menu-item index="speciesAdmin" class="nav-subitem"><i class="el-icon-s-grid"></i> 物种管理</el-menu-item>
        <el-menu-item index="videoAdmin" class="nav-subitem"><i class="el-icon-video-camera"></i> 视频管理</el-menu-item>
      </el-submenu>
      <div class="navbar-right">
        <span class="welcome-text">欢迎,{{ userName }}！</span>
        <img src="/images/index/happy.png" alt="头像" class="user-avatar">
        <el-button v-if="loggedIn" type="text" class="logout-btn" @click="handleLogout">退出</el-button>
      </div>
    </el-menu>
  </div>
</template>

<script>
import { getUser, clearAuth, isLoggedIn, onAuthChange } from '@/utils/auth.js';

export default {
  name: 'AppNavbar',
  props: {
    active: {
      type: String,
      default: 'index'
    }
  },
  data() {
    return {
      userName: '游客',
      loggedIn: false,
      isAdmin: false
    };
  },
  mounted() {
    this.refreshUser();
    // 订阅登录态变化：登录/登出后立即刷新显示
    this._unsub = onAuthChange(() => {
      this.refreshUser();
    });
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  },
  methods: {
    refreshUser() {
      this.loggedIn = isLoggedIn();
      const u = getUser();
      this.userName = u ? u.username : '游客';
      this.isAdmin = !!(u && u.role === 'ROLE_ADMIN');
    },
    handleSelect(index) {
      // 管理后台子菜单的 index 与路由 name 一致，直接跳转
      if (this.$route.name !== index) {
        this.$router.push({ name: index }).catch(() => {});
      }
    },
    handleLogout() {
      this.$confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        clearAuth();
        this.$message.success('已退出登录');
        setTimeout(() => {
          this.$router.push('/login');
        }, 500);
      }).catch(() => {});
    }
  }
};
</script>

<style scoped>
.ocean-navbar.el-menu--horizontal {
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
  background-color: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
  border-bottom: none;
  padding: 1.5vh 1vw;
  overflow-x: auto;
  scrollbar-width: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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
  color: #1e3c72;
  background-color: transparent !important;
  border-bottom: none;
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
  white-space: nowrap;
  padding: 0 1.2vw;
}
.ocean-navbar .nav-item.el-menu-item:hover,
.ocean-navbar .nav-item.el-menu-item:focus {
  color: #006994 !important;
  background-color: transparent !important;
}
.ocean-navbar .nav-item.el-menu-item.is-active {
  color: #006994 !important;
  background-color: transparent !important;
  border-bottom: 0.4vh solid #006994 !important;
}
.navbar-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  color: #1e3c72;
  padding-right: 1vw;
  flex-shrink: 0;
}
.navbar-right .welcome-text { font-size: clamp(11px, 1.1vw, 14px); margin-right: 8px; white-space: nowrap; }
.navbar-right .user-avatar { width: 4vh; height: 4vh; min-width: 28px; min-height: 28px; }
.navbar-right .logout-btn {
  color: #1e3c72;
  margin-left: 8px;
  padding: 0 4px;
  font-size: clamp(11px, 1.1vw, 14px);
}
.navbar-right .logout-btn:hover { color: #006994; }

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
