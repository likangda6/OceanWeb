<template>
  <div class="classify-page">
    <app-navbar :active="'classify'" />

    <!-- 搜索区域 -->
    <div class="search-container fade-in">
      <div class="classification-window">
        <el-select
          v-model="selectedClass"
          placeholder="选择纲"
          class="classification-select-item"
          clearable
          @change="onClassChange"
        >
          <el-option
            v-for="c in classOptions"
            :key="c"
            :label="c"
            :value="c"
          ></el-option>
        </el-select>

        <div class="divider"></div>

        <el-select
          v-model="selectedOrder"
          placeholder="选择目"
          class="classification-select-item"
          clearable
          :disabled="!selectedClass"
          @change="onOrderChange"
        >
          <el-option
            v-for="o in orderOptions"
            :key="o"
            :label="o"
            :value="o"
          ></el-option>
        </el-select>

        <div class="divider"></div>

        <el-select
          v-model="selectedFamily"
          placeholder="选择科"
          class="classification-select-item"
          clearable
          :disabled="!selectedOrder"
        >
          <el-option
            v-for="f in familyOptions"
            :key="f"
            :label="f"
            :value="f"
          ></el-option>
        </el-select>

        <div class="divider"></div>

        <button class="query-button" @click="handleQuery">
          <img src="/images/index/search.png" alt="查询">
        </button>
      </div>
    </div>

    <!-- 结果展示区域 -->
    <div class="results-container" v-show="resultsVisible">
      <div class="results-title">{{ resultsTitle }}</div>
      <div class="loading" v-show="loading">
        <div class="loading-spinner"></div>
        <div>正在加载数据...</div>
      </div>
      <div class="table-responsive">
        <table class="results-table">
          <thead>
            <tr>
              <th>物种</th>
              <th>纲</th>
              <th>目</th>
              <th>科</th>
              <th>图片</th>
              <th>简介</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="animal in results" :key="animal.id">
              <td>{{ animal.name }}</td>
              <td>{{ animal.animalClass }}</td>
              <td>{{ animal.order }}</td>
              <td>{{ animal.family }}</td>
              <td>
                <img
                  :src="animal.imageUrl || placeholderImage"
                  :alt="animal.name"
                  class="animal-image"
                >
              </td>
              <td>
                <span class="view-details" @click="showDetails(animal)">查看详情</span>
              </td>
            </tr>
            <tr v-if="!loading && results.length === 0">
              <td colspan="6" style="text-align: center; padding: 20px; color: #666;">
                没有找到匹配的物种
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog
      :visible.sync="detailsVisible"
      :title="currentAnimal ? currentAnimal.name : '物种详情'"
      custom-class="details-dialog"
      width="60%"
    >
      <div v-if="currentAnimal" class="modal-body">
        <p><strong>纲:</strong> {{ currentAnimal.animalClass }}</p>
        <p><strong>目:</strong> {{ currentAnimal.order }}</p>
        <p><strong>科:</strong> {{ currentAnimal.family }}</p>
        <div style="text-align: center; margin: 15px 0;">
          <img
            :src="currentAnimal.imageUrl || placeholderImageLarge"
            :alt="currentAnimal.name"
            style="max-width: 100%; max-height: 300px; border-radius: 8px;"
          >
        </div>
        <p style="white-space: pre-line;">
          <strong>描述:</strong> {{ currentAnimal.description || '暂无详细描述' }}
        </p>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import AppNavbar from '@/components/Navbar.vue';
import axios from 'axios';

// 静态分类数据（纲 -> 目 -> 科 列表）
const staticData = {
  "哺乳纲": {
    "偶蹄目（鲸亚目）": ["露脊鲸科", "灰鲸科", "须鲸科", "抹香鲸科", "小抹香鲸科", "一角鲸科", "鼠海豚科", "海豚科", "喙鲸科"],
    "海牛目": ["海牛科", "儒艮科"],
    "食肉目": ["耳海豹科", "海豹科", "海象科", "鼬科", "熊科"]
  },
  "辐鳍鱼纲": {
    "鲤形目": ["虎鱼科", "鲤科", "鳅科", "口鱼科"],
    "四齿兽类": ["四齿龙科", "蝠科", "齿齿鱼科", "单棘鱼科", "三棘鱼科", "介形虫科"],
    "鳗鲡目": ["蓝蝽科", "海鳗科", "蛇鱼科", "网口目", "合鳃鱼科", "辣木科", "线鱼科", "锯齿目"],
    "腹骨目": ["海龙科", "大鳞蝽科", "飞马科", "管口昆虫科", "口螈科", "沟线虫科"],
    "鲈形目": ["鲻鱼科", "齿鱼科", "雀科", "鮨科", "唇形科", "虾虎鱼科", "棘鱼科", "沙蚕科", "鲹科", "鲷科", "石首鱼科", "笛鲷科", "金线虫科", "蚋科", "拟蓝蝽科", "介齿蠹科", "布拉米达科", "多形目", "蜈蚣科", "蝽科", "使者科", "雷公藤科", "陆龟科", "企鹅科", "青光眼科", "鳖科", "刺尾鱼科", "玉筋鱼科", "鲈科", "尖吻鲈科", "鲭科", "慈鲷科", "后颌龙科", "毛蚶科", "扁虱科", "软棘鱼科", "食粪螨科", "沙蜂科", "翼龙科", "细鳞鲀科", "脊鳞蝽科", "库氏蝽科", "班乔斯科"],
    "鲯鳅目": ["沙鲛科", "鲯鳅科", "触角亚纲", "头足类", "角蚋科", "巨齿鲨科", "黑鲸科", "奇异鱼科", "蛇科"],
    "口足目": ["胸齿鳐科", "齿鱼科", "蜉蝣科", "磷鱼科", "双翅目"],
    "鲉形目": ["鲉科", "利爪蟾科", "隐翅虫科", "扁头珊瑚科", "蜂科", "蜈蚣科", "指翅目", "海狸科", "蝽科", "鲆科"],
    "鲽形目": ["舌鳎科", "鲽科", "鲻科", "全心虫科", "斑蝽科", "牙鲆科", "斑蝶科", "蝽科"],
    "鲻形目": ["鲻科"],
    "鲱形目": ["鲱科", "鳀科", "足目昆虫科", "锯齿蜂科"],
    "鲶形目": ["鲶科", "斑蝶科", "蝗科", "钝枕蚁科", "甲鲶科", "蜈蚣科", "袋鳖科"],
    "鳕形目": ["大尾目", "布雷格马瑟科", "黑蚁科"],
    "蝾螈目": ["齿龙科", "绿眼鱼科", "副鳞蝽科", "南鱼科", "恒河猴科", "矛头蝽科", "鲵科", "鲎科"],
    "蛇形目": ["蛇科", "甲鱼科", "蜉蝣科"],
    "阿根廷形目": ["小口目", "扁头蠓科", "深海螺科", "阿根廷蜻蜓科"],
    "泽形目": ["蜉蝣科", "副蝽科"],
    "蚋形目": ["蚜科", "新镜科"],
    "白蚁目": ["银纹夜蛾科", "晕龙科", "背棘鱼科"],
    "冠蝽形目": ["鲛科"],
    "蝽形目": ["蝽科", "鲛科"],
    "猿形目": ["沙蚕科"],
    "明虾形目": ["粗鳍鱼科", "银鲹科", "萤火虫科"],
    "淋巴鱼形目": ["角刺科", "鳐科"],
    "囊咽鱼形目": ["广咽鱼科"],
    "鲑形目": ["鲑科"],
    "骨舌鱼目": ["骨舌鱼科", "象鼻鱼科"],
    "脂鲤目": ["脂鲤科"],
    "多鳍鱼目": ["多翅目"],
    "裸足目": ["翼蝠科"]
  },
  "软骨鱼纲": {
    "鳖目": ["鲯鳅科", "尾尾蟾科", "袋熊科", "六棱鱼科", "蛇颈蛙科", "鲽科"],
    "真鲨目": ["鲛科", "三叉戟科", "沙鲛科", "真鲨科"],
    "角鲨目": ["大鳞蠓科", "角鲨科", "翅亚纲"],
    "银鲛目": ["犀牛科", "银鲛科"],
    "六鳃鳗目": ["衣鲨科"],
    "鼠妇目": ["三鲛科"],
    "斜齿鲽目": ["斜纹夜蛾科"]
  },
  "头足纲": {
    "章鱼目": ["章鱼科"],
    "管鱿目": ["真鱿科"],
    "乌贼目": ["乌贼科"],
    "鹦鹉螺目": ["鹦鹉螺科"],
    "蛸形目": ["船蛸科"]
  },
  "双壳纲": {
    "帘蛤目": ["帘蛤科", "砗磲科"],
    "蚶形目": ["牡蛎科"],
    "翼形目": ["扇贝科"],
    "贻贝目": ["贻贝科"]
  },
  "腹足纲": {
    "异腹足目": ["蜗牛科", "塔螺科"],
    "新腹足目": ["芋螺科"],
    "鲍螺目": ["鲍鱼科"],
    "裸鳃目": ["海蛞蝓科"],
    "玉螺目": ["玉螺科"]
  },
  "甲壳纲": {
    "十足目": ["螃蟹总科", "龙虾科", "对虾科", "寄居蟹科", "鎧虾科", "扇虾科", "螯虾科", "蜘蛛蟹科", "梭子蟹科", "拟石蟹科"],
    "藤壶目": ["藤壶科"],
    "糠虾目": ["糠虾科"],
    "口足目": ["虾蛄科"],
    "等足目": ["水虱科"]
  },
  "肢口纲": {
    "鲎目": ["鲎科"]
  },
  "钵水母纲": {
    "根口水母目": ["海蜇科", "水母科", "海月水母科"]
  },
  "六射珊瑚纲": {
    "海葵目": ["海葵科"],
    "石珊瑚目": ["石珊瑚科", "脑珊瑚科"]
  },
  "水螅纲": {
    "僧帽水母目": ["僧帽水母科"],
    "火珊瑚目": ["火珊瑚科"]
  },
  "八射珊瑚纲": {
    "蓝珊瑚目": ["蓝珊瑚科"],
    "海笔目": ["海笔科"],
    "柳珊瑚目": ["海鞭科", "海扇珊瑚科"],
    "软珊瑚目": ["软珊瑚科"]
  },
  "海星纲": {
    "海星目": ["海星科", "棘冠海星科"]
  },
  "海胆纲": {
    "常见海胆目": ["海胆科"]
  },
  "海参纲": {
    "海参目": ["海参科"]
  },
  "海百合纲": {
    "羽状海百合目": ["海百合科"]
  },
  "蛇尾纲": {
    "蛇尾目": ["蛇尾科"]
  },
  "盲鳗": {
    "盲鳗目": ["贻贝科"]
  },
  "石鳃亚纲": {
    "石鳅目": ["石鳃金龟科"]
  }
};

export default {
  name: 'ClassifyQuery',
  components: { AppNavbar },
  data() {
    return {
      selectedClass: '',
      selectedOrder: '',
      selectedFamily: '',
      staticData: staticData,
      results: [],
      loading: false,
      resultsVisible: false,
      detailsVisible: false,
      currentAnimal: null,
      placeholderImage: 'https://via.placeholder.com/80x60?text=No+Image',
      placeholderImageLarge: 'https://via.placeholder.com/300x200?text=No+Image'
    };
  },
  computed: {
    classOptions() {
      return Object.keys(this.staticData);
    },
    orderOptions() {
      if (!this.selectedClass) return [];
      return Object.keys(this.staticData[this.selectedClass] || {});
    },
    familyOptions() {
      if (!this.selectedClass || !this.selectedOrder) return [];
      return this.staticData[this.selectedClass][this.selectedOrder] || [];
    },
    resultsTitle() {
      return `查询结果 (共 ${this.results.length} 个物种)`;
    }
  },
  methods: {
    onClassChange() {
      // 纲变化时清空目与科
      this.selectedOrder = '';
      this.selectedFamily = '';
    },
    onOrderChange() {
      // 目变化时清空科
      this.selectedFamily = '';
    },
    handleQuery() {
      if (!this.selectedClass) {
        this.showAlert('请选择纲');
        return;
      }
      if (!this.selectedOrder) {
        this.showAlert('请选择目');
        return;
      }
      if (!this.selectedFamily) {
        this.showAlert('请选择科');
        return;
      }

      const query = {
        animalClass: this.selectedClass,
        order: this.selectedOrder,
        family: this.selectedFamily
      };
      this.performSearch(query);
    },
    performSearch(query) {
      this.resultsVisible = true;
      this.loading = true;
      axios
        .get('/animals/search', {
          params: {
            animalClass: query.animalClass,
            order: query.order,
            family: query.family
          }
        })
        .then(response => {
          this.displayResults(response.data);
        })
        .catch(error => {
          console.error('Error fetching search results:', error);
          this.showAlert('获取数据失败，请稍后重试');
        })
        .then(() => {
          this.loading = false;
        });
    },
    displayResults(data) {
      this.results = Array.isArray(data) ? data : [];
    },
    showDetails(animal) {
      this.currentAnimal = animal;
      this.detailsVisible = true;
    },
    showAlert(message) {
      this.$message({
        message: message,
        type: 'warning'
      });
    }
  }
};
</script>

<style scoped>
body {
  margin: 0;
  padding: 0;
  -webkit-tap-highlight-color: transparent;
}

.classify-page {
  margin: 0;
  padding: 0;
  width: 100%;
  min-height: 100vh;
  min-height: 100dvh;
  background-image: url('/images/index/ocean11.png');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  font-family: 'Microsoft YaHei', Arial, sans-serif;
  display: flex;
  flex-direction: column;
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

/* 导航栏 */
.navbar {
  display: flex;
  overflow: hidden;
  background-color: rgba(74, 184, 249, 0.6);
  padding: 2vh 0;
  flex-shrink: 0;
  align-items: center;
  position: relative;
  z-index: 10;
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

.title {
  width: 10vw;
  height: 100%;
  background-color: aqua;
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

/* 搜索容器 */
.search {
  width: 100%;
  height: 30%;
}

.search-container {
  width: 70%;
  max-width: 1000px;
  margin: 1vh auto;
  flex-shrink: 0;
}

.classification-window {
  border-radius: 30px;
  width: 100%;
  height: 60px;
  display: flex;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.9);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  padding: 0 15px;
  position: relative;
  transition: all 0.3s;
}

.classification-window:hover {
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

/* el-select 在窗口中的尺寸 */
.classify-page >>> .classification-select-item.el-select {
  flex: 1;
  min-width: 150px;
  margin: 0 10px;
}
.classify-page >>> .classification-select-item .el-input__inner {
  height: 40px;
  line-height: 40px;
  border-radius: 15px;
  text-align: center;
  font-size: 16px;
  background-color: #fff;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  border: none;
}
.classify-page >>> .classification-select-item .el-input__inner::placeholder {
  color: #999;
}

.classification-select {
  position: relative;
  min-width: 150px;
  height: 40px;
  cursor: pointer;
  z-index: 10;
  margin: 0 10px;
  flex: 1;
  user-select: none;
  -webkit-user-select: none;
}

.classification-header {
  height: 100%;
  padding: 0 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  color: #333;
  position: relative;
  border-radius: 15px;
  background-color: white;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
  -webkit-tap-highlight-color: transparent;
}

.classification-header:hover {
  background-color: #f5f5f5;
}

.selected-value {
  flex: 1;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.arrow {
  margin-left: 10px;
  font-size: 12px;
  transition: transform 0.3s;
}

.classification-options {
  position: absolute;
  top: 100%;
  left: 0;
  width: 100%;
  max-height: 0;
  overflow: hidden;
  background-color: white;
  border-radius: 0 0 15px 15px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  transition: max-height 0.3s ease-out, opacity 0.2s ease;
  opacity: 0;
  z-index: 100;
}

.classification-select:hover .classification-options {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #eee;
  border-top: none;
  opacity: 1;
}

.classification-select:hover .arrow {
  transform: rotate(180deg);
}

.classification-option {
  padding: 12px 15px;
  font-size: 14px;
  color: #333;
  transition: all 0.2s;
  border-bottom: 1px solid #f0f0f0;
  -webkit-tap-highlight-color: transparent;
}

.classification-option:last-child {
  border-bottom: none;
}

.classification-option:hover {
  background-color: #1890ff;
  color: white;
}

.classification-option.selected {
  background-color: #1890ff;
  color: white;
}

.query-button {
  width: 50px;
  height: 50px;
  border: none;
  border-radius: 50%;
  margin-left: 15px;
  background-color: #1890ff;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  flex-shrink: 0;
  -webkit-tap-highlight-color: transparent;
}

.query-button:hover {
  background-color: #1478d4;
  transform: scale(1.05);
}

.query-button:active {
  transform: scale(0.95);
}

.query-button img {
  width: 25px;
  height: 25px;
}

.divider {
  width: 1px;
  height: 40px;
  background-color: #ddd;
  margin: 0 5px;
  flex-shrink: 0;
}

/* 结果展示区域 */
.results-container {
  width: 90%;
  max-width: 1200px;
  margin: 30px auto;
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  flex: 1;
}

.results-title {
  font-size: 24px;
  color: #333;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

.results-table th {
  background-color: #1890ff;
  color: white;
  padding: 12px 15px;
  text-align: left;
}

.results-table td {
  padding: 12px 15px;
  border-bottom: 1px solid #eee;
  vertical-align: middle;
}

.results-table tr:nth-child(even) {
  background-color: #f9f9f9;
}

.results-table tr:hover {
  background-color: #f1f1f1;
}

.animal-image {
  width: 80px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
}

.view-details {
  color: #1890ff;
  cursor: pointer;
  text-decoration: underline;
  white-space: nowrap;
  -webkit-tap-highlight-color: transparent;
}

.view-details:hover {
  color: #1478d4;
}

/* 详情弹窗 */
.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

.modal-content {
  background-color: white;
  margin: 10% auto;
  padding: 20px;
  border-radius: 8px;
  width: 60%;
  max-width: 800px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
  position: relative;
  max-height: 80vh;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

.modal-body {
  line-height: 1.6;
  max-height: calc(80vh - 150px);
  overflow-y: auto;
  padding-right: 10px;
  -webkit-overflow-scrolling: touch;
}

.modal-body::-webkit-scrollbar {
  width: 8px;
}

.modal-body::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.modal-body::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: #555;
}

.close-button {
  position: absolute;
  top: 10px;
  right: 15px;
  font-size: 24px;
  font-weight: bold;
  color: #aaa;
  cursor: pointer;
  z-index: 10;
  -webkit-tap-highlight-color: transparent;
}

.close-button:hover {
  color: #333;
}

.modal-title {
  font-size: 40px;
  font-weight: 600;
  margin-bottom: 15px;
}

.loading {
  text-align: center;
  padding: 20px;
}

.loading-spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  border-top: 4px solid #1890ff;
  width: 30px;
  height: 30px;
  animation: spin 1s linear infinite;
  margin: 0 auto 10px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.table-responsive {
  max-height: 500px;
  overflow-y: auto;
  margin-bottom: 20px;
  -webkit-overflow-scrolling: touch;
}

.table-responsive::-webkit-scrollbar {
  width: 8px;
}

.table-responsive::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.table-responsive::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.table-responsive::-webkit-scrollbar-thumb:hover {
  background: #555;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in {
  animation: fadeIn 0.5s ease-out forwards;
}

/* ==================== 响应式设计 ==================== */
@media (max-width: 992px) {
  .classification-select {
    min-width: 120px;
    margin: 0 5px;
  }

  .selected-value {
    font-size: 14px;
  }

  .modal-content {
    width: 80%;
  }
}

@media (max-width: 768px) {
  /* 导航栏改为横向滚动 */
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

  /* 搜索区域移动端 */
  .search-container {
    width: 95%;
    margin: 1.5vh auto;
  }

  .classification-window {
    flex-wrap: wrap;
    height: auto;
    padding: 12px 10px;
    border-radius: 20px;
    gap: 8px;
  }

  .classify-page >>> .classification-select-item.el-select {
    width: 100%;
    margin: 0;
    min-width: auto;
  }

  .classification-select {
    width: 100%;
    margin: 0;
    min-width: auto;
  }

  .classification-header {
    font-size: 15px;
    padding: 10px 12px;
  }

  .divider {
    display: none;
  }

  .query-button {
    width: 100%;
    height: 48px;
    border-radius: 25px;
    margin: 5px 0 0 0;
  }

  /* 移动端禁用悬停展开，改用点击控制（JS处理） */
  .classification-select:hover .classification-options {
    max-height: 0;
    opacity: 0;
    border: none;
  }

  .classification-select:hover .arrow {
    transform: rotate(0deg);
  }

  /* 点击展开样式 */
  .classification-options.open {
    max-height: 250px;
    opacity: 1;
    border: 1px solid #eee;
    border-top: none;
    overflow-y: auto;
  }

  .classification-select.open .arrow {
    transform: rotate(180deg);
  }

  .classification-option {
    padding: 10px 15px;
    font-size: 14px;
  }

  /* 结果区域 */
  .results-container {
    width: 95%;
    margin: 15px auto;
    padding: 12px;
  }

  .results-title {
    font-size: 18px;
    margin-bottom: 12px;
  }

  .results-table th,
  .results-table td {
    padding: 8px 6px;
    font-size: 13px;
  }

  .animal-image {
    width: 60px;
    height: 45px;
  }

  .table-responsive {
    max-height: 400px;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  /* 弹窗移动端 */
  .modal-content {
    width: 92%;
    margin: 15% auto;
    padding: 15px;
    max-height: 85vh;
  }

  .modal-title {
    font-size: 24px;
  }

  .modal-body {
    max-height: calc(85vh - 130px);
    font-size: 14px;
  }

  .close-button {
    top: 8px;
    right: 12px;
    font-size: 22px;
  }
}

/* 更小屏幕 */
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

  .classification-header {
    font-size: 14px;
    padding: 8px 10px;
  }

  .results-table th,
  .results-table td {
    font-size: 11px;
    padding: 6px 4px;
  }

  .animal-image {
    width: 45px;
    height: 35px;
  }
}
</style>
