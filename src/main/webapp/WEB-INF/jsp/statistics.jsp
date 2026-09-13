<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>海洋生物数据可视化</title>
    <script src="/js/echarts.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; font-family: 'Microsoft YaHei', sans-serif; }
        .header { text-align: center; color: #fff; padding: 30px 0; }
        .header h1 { font-size: 2.5rem; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px 40px; }
        .chart-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px; }
        .chart-box { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 8px 32px rgba(0,0,0,0.15); }
        .chart-box h3 { color: #333; margin-bottom: 15px; font-size: 1.1rem; text-align: center; }
        .chart { width: 100%; height: 320px; }
        .loading { text-align: center; color: #fff; padding: 40px; font-size: 1.2rem; }
    </style>
</head>
<body>
    <div class="header">
        <h1>海洋生物数据可视化分析</h1>
    </div>
    <div class="container">
        <div id="loading" class="loading">数据加载中...</div>
        <div id="content" style="display:none;">
            <div class="chart-grid">
                <div class="chart-box">
                    <h3>物种总数统计</h3>
                    <div id="chart-gauge" class="chart"></div>
                </div>
                <div class="chart-box">
                    <h3>分类数量对比</h3>
                    <div id="chart-bar" class="chart"></div>
                </div>
                <div class="chart-box">
                    <h3>分类层级分布</h3>
                    <div id="chart-pie" class="chart"></div>
                </div>
                <div class="chart-box">
                    <h3>物种分类详情</h3>
                    <div id="chart-bar2" class="chart"></div>
                </div>
            </div>
        </div>
    </div>
    <script>
        fetch('/api/statistics')
            .then(res => res.json())
            .then(data => {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('content').style.display = 'block';

                // 仪表盘 - 物种总数
                var gaugeChart = echarts.init(document.getElementById('chart-gauge'));
                gaugeChart.setOption({
                    series: [{
                        type: 'gauge',
                        data: [{ value: data.speciesCount, name: '物种总数' }],
                        max: Math.ceil(data.speciesCount * 1.5),
                        title: { fontSize: 16 },
                        detail: { formatter: '{value}种', fontSize: 24, offsetCenter: [0, '70%'] },
                        axisLine: { lineStyle: { width: 20 } }
                    }]
                });

                // 柱状图 - 分类数量对比
                var barChart = echarts.init(document.getElementById('chart-bar'));
                barChart.setOption({
                    tooltip: { trigger: 'axis' },
                    xAxis: { type: 'category', data: ['纲数', '目数', '科数', '物种总数'] },
                    yAxis: { type: 'value' },
                    series: [{
                        type: 'bar',
                        data: [data.classCount, data.orderCount, data.familyCount, data.speciesCount],
                        itemStyle: {
                            color: function(params) {
                                var colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666'];
                                return colors[params.dataIndex];
                            },
                            borderRadius: [8, 8, 0, 0]
                        },
                        label: { show: true, position: 'top' }
                    }]
                });

                // 饼图 - 分类层级分布
                var pieChart = echarts.init(document.getElementById('chart-pie'));
                pieChart.setOption({
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

                // 柱状图2 - 分类详情
                var bar2Chart = echarts.init(document.getElementById('chart-bar2'));
                bar2Chart.setOption({
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

                // 响应式
                window.addEventListener('resize', function() {
                    gaugeChart.resize();
                    barChart.resize();
                    pieChart.resize();
                    bar2Chart.resize();
                });
            })
            .catch(err => {
                document.getElementById('loading').innerHTML = '数据加载失败: ' + err.message;
            });
    </script>
</body>
</html>
