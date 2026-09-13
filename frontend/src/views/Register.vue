<template>
  <div class="register-page">
    <div class="register-card">
      <div class="register-header">
        <img src="/images/newlogo.png" alt="logo" class="logo">
        <h1 class="title">用户注册</h1>
        <p class="subtitle">加入海洋生物图鉴</p>
      </div>

      <el-form ref="registerForm" :model="form" :rules="rules" label-position="top" @submit.native.prevent="handleRegister">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" prefix-icon="el-icon-user" placeholder="请输入用户名" clearable />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" prefix-icon="el-icon-phone" placeholder="请输入 11 位手机号" clearable maxlength="11" />
        </el-form-item>
        <el-form-item label="验证码" prop="code">
          <div class="code-row">
            <el-input v-model="form.code" prefix-icon="el-icon-message" placeholder="请输入 6 位验证码" clearable maxlength="6" class="code-input" />
            <el-button type="primary" plain class="send-btn" :disabled="codeBtn.disabled || !canSendCode" :loading="codeSending" @click="sendCode">
              {{ codeBtn.text }}
            </el-button>
          </div>
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" prefix-icon="el-icon-lock" type="password" placeholder="请输入密码（6-30位）" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm">
          <el-input v-model="form.confirm" prefix-icon="el-icon-lock" type="password" placeholder="请再次输入密码" show-password @keyup.enter.native="handleRegister" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="submit-btn" :loading="loading" @click="handleRegister">注 册</el-button>
        </el-form-item>
        <div class="form-footer">
          <span>已有账号？</span>
          <el-button type="text" @click="goLogin">前往登录</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Register',
  data() {
    const validateConfirm = (rule, value, callback) => {
      if (value !== this.form.password) {
        callback(new Error('两次输入的密码不一致'));
      } else {
        callback();
      }
    };
    const validatePhone = (rule, value, callback) => {
      if (!value) {
        callback(new Error('请输入手机号'));
      } else if (!/^1[3-9]\d{9}$/.test(value)) {
        callback(new Error('手机号格式不正确'));
      } else {
        callback();
      }
    };
    return {
      form: {
        username: '',
        phone: '',
        code: '',
        password: '',
        confirm: ''
      },
      rules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
          { min: 2, max: 30, message: '长度在 2 到 30 个字符', trigger: 'blur' }
        ],
        phone: [
          { required: true, validator: validatePhone, trigger: 'blur' }
        ],
        code: [
          { required: true, message: '请输入验证码', trigger: 'blur' },
          { min: 6, max: 6, message: '验证码为 6 位数字', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, max: 30, message: '长度在 6 到 30 位字符', trigger: 'blur' }
        ],
        confirm: [
          { required: true, message: '请再次输入密码', trigger: 'blur' },
          { validator: validateConfirm, trigger: 'blur' }
        ]
      },
      loading: false,
      codeSending: false,
      codeBtn: {
        text: '获取验证码',
        disabled: false
      },
      countdownTimer: null
    };
  },
  computed: {
    canSendCode() {
      return /^1[3-9]\d{9}$/.test(this.form.phone);
    }
  },
  beforeDestroy() {
    if (this.countdownTimer) clearInterval(this.countdownTimer);
  },
  methods: {
    async sendCode() {
      if (!this.canSendCode) {
        this.$message.warning('请先输入正确的手机号');
        return;
      }
      this.codeSending = true;
      try {
        const params = new URLSearchParams();
        params.append('phone', this.form.phone);
        const res = await fetch('/api/sms/code', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: params
        });
        const data = await res.json();
        if (data.code === 200) {
          this.$message.success('验证码已发送，5 分钟内有效');
          this.startCountdown(60);
        } else if (data.code === 429) {
          // 后端限流，提示剩余秒数并自动倒计时
          this.$message.warning(data.message || '发送过于频繁');
          const match = (data.message || '').match(/(\d+)\s*秒/);
          const wait = match ? parseInt(match[1]) : 60;
          this.startCountdown(wait);
        } else {
          this.$message.error(data.message || '验证码发送失败');
        }
      } catch (err) {
        this.$message.error('网络错误，验证码发送失败');
      } finally {
        this.codeSending = false;
      }
    },
    startCountdown(seconds) {
      let remain = seconds;
      this.codeBtn.disabled = true;
      this.codeBtn.text = `${remain} 秒后重发`;
      this.countdownTimer = setInterval(() => {
        remain--;
        if (remain <= 0) {
          clearInterval(this.countdownTimer);
          this.codeBtn.disabled = false;
          this.codeBtn.text = '获取验证码';
        } else {
          this.codeBtn.text = `${remain} 秒后重发`;
        }
      }, 1000);
    },
    handleRegister() {
      this.$refs.registerForm.validate(async (valid) => {
        if (!valid) return;
        this.loading = true;
        try {
          const params = new URLSearchParams();
          params.append('username', this.form.username);
          params.append('phone', this.form.phone);
          params.append('code', this.form.code);
          params.append('password', this.form.password);
          const res = await fetch('/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
          });
          const data = await res.json();
          if (data.code === 200) {
            this.$message.success('注册成功，请登录');
            setTimeout(() => {
              this.$router.push('/login');
            }, 800);
          } else {
            this.$message.error(data.message || '注册失败');
          }
        } catch (err) {
          this.$message.error('网络错误，注册失败');
        } finally {
          this.loading = false;
        }
      });
    },
    goLogin() {
      this.$router.push('/login');
    }
  }
};
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #36d1dc 100%);
  padding: 20px;
}
.register-card {
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
.register-header {
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
.code-row {
  display: flex;
  gap: 10px;
  align-items: center;
}
.code-input {
  flex: 1;
}
.send-btn {
  flex-shrink: 0;
  width: 130px;
  height: 40px;
  padding: 0 10px;
  font-size: 13px;
  border-radius: 6px;
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
</style>
