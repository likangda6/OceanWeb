import Vue from 'vue';
import VueRouter from 'vue-router';
import { isLoggedIn, getUser, setUser, getToken } from '@/utils/auth.js';
import http from '@/utils/auth.js';

Vue.use(VueRouter);

// 路由使用 hash 模式，避免后端 fallback 配置
const routes = [
  { path: '/', redirect: '/hello' },
  // 公开页面
  { path: '/hello', name: 'hello', component: () => import('@/views/Hello.vue') },
  { path: '/login', name: 'login', component: () => import('@/views/Login.vue'), meta: { guest: true } },
  { path: '/register', name: 'register', component: () => import('@/views/Register.vue'), meta: { guest: true } },
  // 受保护页面：需登录后访问
  { path: '/index', name: 'index', component: () => import('@/views/Index.vue'), meta: { requiresAuth: true } },
  { path: '/classify', name: 'classify', component: () => import('@/views/ClassifyQuery.vue'), meta: { requiresAuth: true } },
  { path: '/SimplyQuery', name: 'simplyQuery', component: () => import('@/views/SimplyQuery.vue'), meta: { requiresAuth: true } },
  { path: '/ai', name: 'ai', component: () => import('@/views/AiRobot.vue'), meta: { requiresAuth: true } },
  { path: '/show', name: 'show', component: () => import('@/views/Show.vue'), meta: { requiresAuth: true } },
  { path: '/defend', name: 'defend', component: () => import('@/views/DefendSea.vue'), meta: { requiresAuth: true } },
  { path: '/game', name: 'game', component: () => import('@/views/PlayGame.vue'), meta: { requiresAuth: true } },
  { path: '/videos', name: 'videoList', component: () => import('@/views/VideoList.vue'), meta: { requiresAuth: true } },
  { path: '/videos/:id', name: 'videoPlay', component: () => import('@/views/VideoPlay.vue'), meta: { requiresAuth: true } },
  { path: '/statistics', name: 'statistics', component: () => import('@/views/Statistics.vue'), meta: { requiresAuth: true } },
  // 管理后台：仅管理员可访问
  { path: '/admin/dashboard', name: 'dashboard', component: () => import('@/views/Dashboard.vue'), meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/admin/species', name: 'speciesAdmin', component: () => import('@/views/SpeciesAdmin.vue'), meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/admin/videos', name: 'videoAdmin', component: () => import('@/views/VideoAdmin.vue'), meta: { requiresAuth: true, requiresAdmin: true } }
];

const router = new VueRouter({
  mode: 'hash',
  routes
});

// 验证 token 有效性并刷新用户信息（防止刷新后 localStorage 数据过期）
let verifyPromise = null;
function verifyToken() {
  if (verifyPromise) return verifyPromise;
  verifyPromise = http.get('/api/auth/me').then(res => {
    if (res.data && res.data.code === 200 && res.data.data) {
      setUser(res.data.data);
    }
    verifyPromise = null;
    return res.data.data;
  }).catch(() => {
    verifyPromise = null;
    return null;
  });
  return verifyPromise;
}

// 全局前置守卫：未登录访问受保护页面时跳转到登录页；非管理员访问管理后台跳转首页
router.beforeEach(async (to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!isLoggedIn()) {
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      });
      return;
    }
    // 管理员权限校验：刷新页面时先验证 token 并获取最新角色
    if (to.matched.some(record => record.meta.requiresAdmin)) {
      try {
        const user = await verifyToken();
        if (!user) {
          // token 无效，跳转登录
          next({ path: '/login', query: { redirect: to.fullPath } });
          return;
        }
        if (user.role !== 'ROLE_ADMIN') {
          next({ path: '/index' });
          return;
        }
      } catch (e) {
        // 验证失败，允许继续（组件加载时会再次处理 403）
        const localUser = getUser();
        if (!localUser || localUser.role !== 'ROLE_ADMIN') {
          next({ path: '/index' });
          return;
        }
      }
    }
    next();
  } else if (to.matched.some(record => record.meta.guest)) {
    // 已登录用户访问登录/注册页时直接跳转首页
    if (isLoggedIn()) {
      next({ path: '/index' });
    } else {
      next();
    }
  } else {
    next();
  }
});

export default router;
