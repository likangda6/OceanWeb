<template>
  <div class="statistics-page">
    <app-navbar :active="'statistics'" />
    <div class="header">
      <h1>海洋生物数据可视化分析</h1>
    </div>
    <div class="container">
      <div v-if="loading" class="loading">数据加载中...</div>
      <div v-else-if="error" class="loading">数据加载失败: {{ error }}</div>
      <div v-else class="chart-grid">
        <div class="chart-box">
          <h3>物种总数统计</h3>
          <div ref="chartGauge" class="chart"></div>
        </div>
        <div class="chart-box">
          <h3>分类数量对比</h3>
          <div ref="chartBar" class="chart"></div>
        </div>
        <div class="chart-box">
          <h3>分类层级分布</h3>
          <div ref="chartPie" class="chart"></div>
        </div>
        <div class="chart-box">
          <h3>物种分类详情</h3>
          <div ref="chartBar2" class="chart"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import AppNavbar from '@/components/Navbar.vue';
import * as echarts from 'echarts';
import axios from 'axios';

export default {
  name: 'Statistics',
  components: { AppNavbar },
  data() {
    return {
      loading: true,
      error: '',
      stats: null,
      charts: []
    };
  },
  mounted() {
    this.loadStatistics();
    window.addEventListener('resize', this.handleResize);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
    this.charts.forEach(c => c && c.dispose && c.dispose());
  },
  methods: {
    loadStatistics() {
      axios.get('/api/statistics')
        .then(res => {
          this.stats = res.data;
          this.loading = false;
          this.$nextTick(this.renderCharts);
        })
        .catch(err => {
          this.error = err.message || '请求失败';
          this.loading = false;
        });
    },
    renderCharts() {
      const data = this.stats;
      this.charts = [];

      // 仪表盘 - 物种总数
      const gauge = echarts.init(this.$refs.chartGauge);
      gauge.setOption({
        series: [{
          type: 'gauge',
          data: [{ value: data.speciesCount, name: '物种总数' }],
          max: Math.ceil(data.speciesCount * 1.5),
          title: { fontSize: 16 },
          detail: { formatter: '{value}种', fontSize: 24, offsetCenter: [0, '70%'] },
          axisLine: { lineStyle: { width: 20 } }
        }]
      });
      this.charts.push(gauge);

      // 柱状图 - 分类数量对比
      const bar = echarts.init(this.$refs.chartBar);
      bar.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: ['纲数', '目数', '科数', '物种总数'] },
        yAxis: { type: 'value' },
        series: [{
          type: 'bar',
          data: [data.classCount, data.orderCount, data.familyCount, data.speciesCount],
          itemStyle: {
            color(params) {
              const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666'];
              return colors[params.dataIndex];
            },
            borderRadius: [8, 8, 0, 0]
          },
          label: { show: true, position: 'top' }
        }]
      });
      this.charts.push(bar);

      // 饼图 - 分类层级分布
      const pie = echarts.init(this.$refs.chartPie);
      pie.setOption({
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        legend: { bottom: '5%' },
        series: [{
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          data: [
            { value: data.classCount, name: '纲数' },
            { value: data.orderCount, name: '目数' },
            { value: data.familyCount, name: '科数' },
            { value: data.speciesCount, name: '物种总数' }
          ],
          label: { show: true, formatter: '{b}: {c}' },
          emphasis: { label: { show: true, fontSize: 18, fontWeight: 'bold' } }
        }]
      });
      this.charts.push(pie);

      // 柱状图2 - 分类详情
      const bar2 = echarts.init(this.$refs.chartBar2);
      bar2.setOption({
        tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
        legend: { data: ['数量'] },
        xAxis: { type: 'value' },
        yAxis: { type: 'category', data: ['物种总数', '科数', '目数', '纲数'] },
        series: [{
          type: 'bar',
          data: [data.speciesCount, data.familyCount, data.orderCount, data.classCount],
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: '#83bff6' },
              { offset: 1, color: '#188df0' }
            ]),
            borderRadius: [0, 8, 8, 0]
          },
          label: { show: true, position: 'right' }
        }]
      });
      this.charts.push(bar2);
    },
    handleResize() {
      this.charts.forEach(c => c && c.resize && c.resize());
    }
  }
};
</script>

<style scoped>
.statistics-page {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  font-family: 'Microsoft YaHei', sans-serif;
  box-sizing: border-box;
}
* { box-sizing: border-box; }
.header {
  text-align: center;
  color: #fff;
  padding: 30px 0;
}
.header h1 {
  font-size: 2.5rem;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
  margin: 0;
}
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px 40px;
}
.chart-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 20px;
}
.chart-box {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.15);
}
.chart-box h3 {
  color: #333;
  margin-bottom: 15px;
  font-size: 1.1rem;
  text-align: center;
}
.chart {
  width: 100%;
  height: 320px;
}
.loading {
  text-align: center;
  color: #fff;
  padding: 40px;
  font-size: 1.2rem;
}

@media (max-width: 768px) {
  .chart-grid { grid-template-columns: 1fr; }
  .header h1 { font-size: 1.8rem; }
  .chart { height: 260px; }
}
</style>
