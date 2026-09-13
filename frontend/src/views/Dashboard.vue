<template>
  <div class="dashboard-page">
    <app-navbar :active="'dashboard'" />

    <div class="dashboard-container">
      <div class="dashboard-header">
        <h1><i class="el-icon-monitor"></i> 管理后台仪表盘</h1>
        <div class="header-right">
          <el-tag :type="autoRefresh ? 'success' : 'info'" effect="dark" size="medium">
            <i :class="autoRefresh ? 'el-icon-loading' : 'el-icon-video-pause'"></i>
            {{ autoRefresh ? '实时监控中' : '已暂停' }}
          </el-tag>
          <el-switch v-model="autoRefresh" active-text="自动刷新" @change="toggleAutoRefresh"></el-switch>
          <el-button type="primary" size="small" icon="el-icon-refresh" @click="loadDashboard">手动刷新</el-button>
          <el-button type="warning" size="small" icon="el-icon-s-management" @click="goSpeciesAdmin">物种管理</el-button>
        </div>
      </div>

      <!-- 物种数量统计卡片 -->
      <el-row :gutter="20" class="stat-cards">
        <el-col :xs="12" :sm="12" :md="6">
          <div class="stat-card fish">
            <div class="stat-icon"><i class="el-icon-fish"></i></div>
            <div class="stat-info">
              <div class="stat-label">鱼类物种</div>
              <div class="stat-value">{{ stats.fishCount || 0 }}</div>
            </div>
          </div>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6">
          <div class="stat-card whale">
            <div class="stat-icon"><i class="el-icon-magic-stick"></i></div>
            <div class="stat-info">
              <div class="stat-label">鲸类物种</div>
              <div class="stat-value">{{ stats.whaleCount || 0 }}</div>
            </div>
          </div>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6">
          <div class="stat-card invertebrate">
            <div class="stat-icon"><i class="el-icon-collection"></i></div>
            <div class="stat-info">
              <div class="stat-label">无脊椎动物</div>
              <div class="stat-value">{{ stats.invertebrateCount || 0 }}</div>
            </div>
          </div>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6">
          <div class="stat-card total">
            <div class="stat-icon"><i class="el-icon-data-analysis"></i></div>
            <div class="stat-info">
              <div class="stat-label">物种总数</div>
              <div class="stat-value">{{ stats.totalCount || 0 }}</div>
            </div>
          </div>
        </el-col>
      </el-row>

      <!-- 图表区 -->
      <el-row :gutter="20" class="chart-row">
        <el-col :xs="24" :md="12">
          <el-card shadow="hover" class="chart-card">
            <div slot="header" class="chart-header">
              <span><i class="el-icon-pie-chart"></i> 物种分布占比</span>
            </div>
            <div ref="pieChart" class="chart-box"></div>
          </el-card>
        </el-col>
        <el-col :xs="24" :md="12">
          <el-card shadow="hover" class="chart-card">
            <div slot="header" class="chart-header">
              <span><i class="el-icon-data-line"></i> 物种数量趋势（最近更新）</span>
            </div>
            <div ref="barChart" class="chart-box"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 系统信息 -->
      <el-card shadow="hover" class="info-card">
        <div slot="header" class="chart-header">
          <span><i class="el-icon-info"></i> 系统信息</span>
        </div>
        <el-descriptions :column="3" border size="medium">
          <el-descriptions-item label="系统名称">海洋生物图鉴管理后台</el-descriptions-item>
          <el-descriptions-item label="当前登录用户">{{ currentUser.username }}</el-descriptions-item>
          <el-descriptions-item label="用户角色">
            <el-tag type="danger" size="small">{{ currentUser.role }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="数据最后更新">{{ lastUpdateTime }}</el-descriptions-item>
          <el-descriptions-item label="自动刷新间隔">10 秒</el-descriptions-item>
          <el-descriptions-item label="服务状态">
            <el-tag type="success" size="small">运行中</el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </el-card>
    </div>
  </div>
</template>

<script>
import AppNavbar from '@/components/Navbar.vue';
import http from '@/utils/auth.js';
import { getUser } from '@/utils/auth.js';
import echarts from 'echarts';

export default {
  name: 'Dashboard',
  components: { AppNavbar },
  data() {
    return {
      stats: { fishCount: 0, whaleCount: 0, invertebrateCount: 0, totalCount: 0 },
      autoRefresh: true,
      refreshTimer: null,
      lastUpdateTime: '-',
      currentUser: getUser() || { username: '管理员', role: 'ROLE_ADMIN' },
      pieChartInstance: null,
      barChartInstance: null,
      trendData: []
    };
  },
  mounted() {
    this.loadDashboard();
    this.startAutoRefresh();
    window.addEventListener('resize', this.resizeCharts);
  },
  beforeDestroy() {
    this.stopAutoRefresh();
    window.removeEventListener('resize', this.resizeCharts);
    if (this.pieChartInstance) this.pieChartInstance.dispose();
    if (this.barChartInstance) this.barChartInstance.dispose();
  },
  methods: {
    async loadDashboard() {
      try {
        const res = await http.get('/api/admin/species/dashboard');
        if (res.data && res.data.code === 200) {
          this.stats = res.data.data;
          const now = new Date();
          this.lastUpdateTime = now.toLocaleString();
          // 趋势数据（保存最近 10 次快照）
          this.trendData.push({
            time: now.toLocaleTimeString(),
            fish: this.stats.fishCount,
            whale: this.stats.whaleCount,
            invertebrate: this.stats.invertebrateCount
          });
          if (this.trendData.length > 10) this.trendData.shift();
          this.renderCharts();
        }
      } catch (err) {
        if (err.response) {
          const status = err.response.status;
          if (status === 401) {
            // 401 已由拦截器处理（跳转登录）
            return;
          }
          if (status === 403) {
            this.$message.error('权限不足，仅管理员可访问');
            this.$router.push('/index');
            return;
          }
        }
        this.$message.error('加载统计数据失败');
      }
    },
    renderCharts() {
      this.$nextTick(() => {
        // 饼图
        if (!this.pieChartInstance && this.$refs.pieChart) {
          this.pieChartInstance = echarts.init(this.$refs.pieChart);
        }
        if (this.pieChartInstance) {
          this.pieChartInstance.setOption({
            tooltip: { trigger: 'item', formatter: '{a} <br/>{b}: {c} ({d}%)' },
            legend: { orient: 'vertical', right: 10, top: 'center' },
            series: [{
              name: '物种数量',
              type: 'pie',
              radius: ['40%', '70%'],
              center: ['40%', '50%'],
              data: [
                { value: this.stats.fishCount, name: '鱼类', itemStyle: { color: '#1e88e5' } },
                { value: this.stats.whaleCount, name: '鲸类', itemStyle: { color: '#43a047' } },
                { value: this.stats.invertebrateCount, name: '无脊椎动物', itemStyle: { color: '#fb8c00' } }
              ]
            }]
          });
        }
        // 柱状图
        if (!this.barChartInstance && this.$refs.barChart) {
          this.barChartInstance = echarts.init(this.$refs.barChart);
        }
        if (this.barChartInstance) {
          this.barChartInstance.setOption({
            tooltip: { trigger: 'axis' },
            legend: { data: ['鱼类', '鲸类', '无脊椎动物'], top: 5 },
            grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
            xAxis: { type: 'category', data: this.trendData.map(d => d.time) },
            yAxis: { type: 'value' },
            series: [
              { name: '鱼类', type: 'bar', data: this.trendData.map(d => d.fish), itemStyle: { color: '#1e88e5' } },
              { name: '鲸类', type: 'bar', data: this.trendData.map(d => d.whale), itemStyle: { color: '#43a047' } },
              { name: '无脊椎动物', type: 'bar', data: this.trendData.map(d => d.invertebrate), itemStyle: { color: '#fb8c00' } }
            ]
          });
        }
      });
    },
    resizeCharts() {
      if (this.pieChartInstance) this.pieChartInstance.resize();
      if (this.barChartInstance) this.barChartInstance.resize();
    },
    startAutoRefresh() {
      this.stopAutoRefresh();
      if (this.autoRefresh) {
        this.refreshTimer = setInterval(() => {
          this.loadDashboard();
        }, 10000);
      }
    },
    stopAutoRefresh() {
      if (this.refreshTimer) {
        clearInterval(this.refreshTimer);
        this.refreshTimer = null;
      }
    },
    toggleAutoRefresh(val) {
      if (val) {
        this.startAutoRefresh();
        this.$message.success('已开启实时监控');
      } else {
        this.stopAutoRefresh();
        this.$message.info('已暂停实时监控');
      }
    },
    goSpeciesAdmin() {
      this.$router.push('/admin/species');
    }
  }
};
</script>

<style scoped>
.dashboard-page {
  min-height: 100vh;
  background-image: url('/images/780.jpg');
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
}
.dashboard-container {
  max-width: 1400px;
  margin: 20px auto;
  padding: 24px;
  background-color: rgba(255, 255, 255, 0.85);
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 24px;
}
.dashboard-header h1 {
  margin: 0;
  color: #1e3c72;
  font-size: 26px;
}
.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.stat-cards { margin-bottom: 24px; }
.stat-card {
  display: flex;
  align-items: center;
  padding: 24px;
  border-radius: 12px;
  color: #fff;
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
  margin-bottom: 12px;
  transition: transform 0.3s;
}
.stat-card:hover { transform: translateY(-4px); }
.stat-card.fish { background: linear-gradient(135deg, #1e88e5, #42a5f5); }
.stat-card.whale { background: linear-gradient(135deg, #43a047, #66bb6a); }
.stat-card.invertebrate { background: linear-gradient(135deg, #fb8c00, #ffa726); }
.stat-card.total { background: linear-gradient(135deg, #8e24aa, #ab47bc); }
.stat-icon {
  font-size: 42px;
  margin-right: 18px;
  opacity: 0.9;
}
.stat-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 4px;
}
.stat-value {
  font-size: 32px;
  font-weight: bold;
}
.chart-row { margin-bottom: 24px; }
.chart-card { border-radius: 12px; }
.chart-header {
  font-weight: bold;
  color: #1e3c72;
}
.chart-box {
  width: 100%;
  height: 320px;
}
.info-card { border-radius: 12px; }
@media (max-width: 768px) {
  .dashboard-header h1 { font-size: 20px; }
  .stat-value { font-size: 24px; }
  .chart-box { height: 240px; }
}
</style>
