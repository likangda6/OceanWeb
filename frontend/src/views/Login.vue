<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-header">
        <img src="/images/newlogo.png" alt="logo" class="logo">
        <h1 class="title">海洋生物图鉴</h1>
        <p class="subtitle">WHALEQUEST: MARINE BIO EXPLORER</p>
      </div>

      <el-form ref="loginForm" :model="form" :rules="rules" label-position="top" @submit.native.prevent="handleLogin">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" prefix-icon="el-icon-user" placeholder="请输入用户名" clearable />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" prefix-icon="el-icon-lock" type="password" placeholder="请输入密码" show-password @keyup.enter.native="handleLogin" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="submit-btn" :loading="loading" @click="handleLogin">登 录</el-button>
        </el-form-item>
        <div class="form-footer">
          <span>还没有账号？</span>
          <el-button type="text" @click="goRegister">立即注册</el-button>
        </div>
        <div class="form-footer back-home">
          <el-button type="text" @click="goHome">返回首页</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script>
import { setToken, setUser } from '@/utils/auth.js';
import http from '@/utils/auth.js';

export default {
  name: 'Login',
  data() {
    return {
      form: {
        username: '',
        password: ''
      },
      rules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
          { min: 2, max: 30, message: '长度在 2 到 30 个字符', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, max: 30, message: '长度在 6 到 30 个字符', trigger: 'blur' }
        ]
      },
      loading: false
    };
  },
  methods: {
    handleLogin() {
      this.$refs.loginForm.validate(async (valid) => {
        if (!valid) return;
        this.loading = true;
        try {
          const params = new URLSearchParams();
          params.append('username', this.form.username);
          params.append('password', this.form.password);
          const res = await fetch('/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
          });
          const data = await res.json();
          if (data.code === 200 && data.data) {
            setToken(data.data.token);
            // 先用登录返回的信息初始化用户态，触发 Navbar 刷新
            setUser({
              username: data.data.username,
              role: data.data.role
            });
            // 再调用 /api/auth/me 拉取最新角色（防止数据库已提升权限但旧缓存）
            try {
              const meRes = await http.get('/api/auth/me');
              if (meRes.data && meRes.data.code === 200 && meRes.data.data) {
                setUser({
                  username: meRes.data.data.username,
                  role: meRes.data.data.role
                });
              }
            } catch (e) {
              // 拉取失败则保留登录返回的信息
            }
            this.$message.success('登录成功');
            const redirect = this.$route.query.redirect || '/index';
            setTimeout(() => {
              this.$router.push(redirect);
            }, 500);
          } else {
            this.$message.error(data.message || '登录失败');
          }
        } catch (err) {
          this.$message.error('网络错误，登录失败');
        } finally {
          this.loading = false;
        }
      });
    },
    goRegister() {
      this.$router.push('/register');
    },
    goHome() {
      this.$router.push('/hello');
    }
  }
};
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #36d1dc 100%);
  padding: 20px;
}
.login-card {
  width: 100%;
  max-width: 420px;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16px;
  padding: 40px 35px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: cardIn 0.5s ease;
}
@keyframes cardIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.login-header {
  text-align: center;
  margin-bottom: 30px;
}
.logo {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin-bottom: 12px;
}
.title {
  font-size: 26px;
  color: #1e3c72;
  margin: 0 0 6px 0;
  font-family: 'STXingkai', 'KaiTi', '楷体', cursive;
}
.subtitle {
  font-size: 12px;
  color: #888;
  letter-spacing: 1px;
  margin: 0;
}
.submit-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
  letter-spacing: 4px;
  border-radius: 22px;
}
.form-footer {
  text-align: center;
  margin-top: 8px;
  font-size: 14px;
  color: #666;
}
.form-footer.back-home {
  margin-top: 4px;
}
</style>
