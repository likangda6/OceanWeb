import axios from 'axios';

const TOKEN_KEY = 'oceanweb_token';
const USER_KEY = 'oceanweb_user';

// 简易事件总线：登录/登出时通知所有组件刷新
const listeners = new Set();
export function onAuthChange(fn) {
  listeners.add(fn);
  return () => listeners.delete(fn);
}
function emitAuthChange() {
  listeners.forEach(fn => fn());
}

// Token 管理
export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token);
}

export function getUser() {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch (e) {
    return null;
  }
}

export function setUser(user) {
  localStorage.setItem(USER_KEY, JSON.stringify(user));
  emitAuthChange();
}

export function clearAuth() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
  emitAuthChange();
}

export function isLoggedIn() {
  return !!getToken();
}

export function isAdmin() {
  const u = getUser();
  return !!(u && u.role === 'ROLE_ADMIN');
}

// axios 实例，统一注入 Authorization 头
const http = axios.create({
  baseURL: '',
  timeout: 15000
});

http.interceptors.request.use(
  config => {
    const token = getToken();
    if (token) {
      config.headers['Authorization'] = 'Bearer ' + token;
    }
    return config;
  },
  error => Promise.reject(error)
);

http.interceptors.response.use(
  response => response,
  error => {
    if (error.response) {
      const status = error.response.status;
      // 401：Token 失效/未登录，清除登录态并跳转登录
      if (status === 401) {
        clearAuth();
        if (location.hash.indexOf('#/login') !== 0) {
          location.hash = '#/login';
        }
      }
      // 403：权限不足（非管理员访问管理接口），不清除 token，仅提示
      // 不在此处跳转，由组件自行处理提示信息
    }
    return Promise.reject(error);
  }
);

export default http;
