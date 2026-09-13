<template>
  <div class="body video-list-page">
    <app-navbar :active="'videoList'" />
    <div class="center-body">
      <div class="filter-bar">
        <el-radio-group v-model="currentCategory" @change="handleCategoryChange" size="medium">
          <el-radio-button label="">全部</el-radio-button>
          <el-radio-button label="科普视频">科普视频</el-radio-button>
          <el-radio-button label="记录片段">记录片段</el-radio-button>
        </el-radio-group>
      </div>
      <div class="video-grid" v-loading="loading">
        <el-row :gutter="20" v-if="videos.length > 0">
          <el-col :xs="12" :sm="8" :md="6" v-for="video in videos" :key="video.id">
            <div class="video-card" @click="goToPlay(video)">
              <div class="card-cover">
                <img :src="video.coverUrl || '/images/index/ocean11.png'" :alt="video.title" class="cover-img" />
                <div class="play-overlay"><i class="el-icon-video-play"></i></div>
                <span class="duration-tag" v-if="video.duration">{{ formatDuration(video.duration) }}</span>
              </div>
              <div class="card-body">
                <h3 class="card-title">{{ video.title }}</h3>
                <el-tag size="mini" type="info">{{ video.category }}</el-tag>
              </div>
            </div>
          </el-col>
        </el-row>
        <el-empty v-else-if="!loading" description="暂无视频"></el-empty>
      </div>
      <div class="pagination-wrap" v-if="total > 0">
        <el-pagination
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="pageSize"
          :current-page.sync="currentPage"
          @current-change="fetchVideos"
        ></el-pagination>
      </div>
    </div>
  </div>
</template>

<script>
import http from '@/utils/auth.js';
import AppNavbar from '@/components/Navbar.vue';

export default {
  name: 'VideoList',
  components: { AppNavbar },
  data() {
    return {
      videos: [],
      loading: false,
      currentPage: 1,
      pageSize: 12,
      total: 0,
      currentCategory: ''
    };
  },
  mounted() {
    this.fetchVideos();
  },
  methods: {
    async fetchVideos() {
      this.loading = true;
      try {
        const res = await http.get('/api/videos', {
          params: { page: this.currentPage, size: this.pageSize, category: this.currentCategory || undefined }
        });
        if (res.data.code === 200) {
          this.videos = res.data.data.records || [];
          this.total = res.data.data.total || 0;
        }
      } catch (e) {
        this.$message.error('获取视频列表失败');
      } finally {
        this.loading = false;
      }
    },
    handleCategoryChange() {
      this.currentPage = 1;
      this.fetchVideos();
    },
    goToPlay(video) {
      this.$router.push({ name: 'videoPlay', params: { id: video.id } });
    },
    formatDuration(seconds) {
      if (!seconds) return '';
      const m = Math.floor(seconds / 60);
      const s = Math.floor(seconds % 60);
      return `${m}:${s < 10 ? '0' : ''}${s}`;
    }
  }
};
</script>

<style scoped>
.video-list-page {
  min-height: 100vh;
  background: url('/images/780.jpg') center/cover no-repeat fixed;
}
.center-body {
  max-width: 1200px;
  margin: 4vh auto;
  padding: 2vh 2vw;
  background-color: rgba(255,255,255,0.92);
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
}
.filter-bar { text-align: center; margin-bottom: 2vh; }
.video-grid { min-height: 200px; }
.video-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  margin-bottom: 20px;
}
.video-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.2);
}
.card-cover { position: relative; width: 100%; padding-top: 56.25%; overflow: hidden; }
.cover-img {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
  object-fit: cover;
}
.play-overlay {
  position: absolute; top: 0; left: 0; right: 0; bottom: 0;
  display: flex; align-items: center; justify-content: center;
  background: rgba(0,0,0,0.3); opacity: 0; transition: opacity 0.3s;
}
.video-card:hover .play-overlay { opacity: 1; }
.play-overlay i { font-size: 3vw; color: #fff; }
.duration-tag {
  position: absolute; bottom: 8px; right: 8px;
  background: rgba(0,0,0,0.7); color: #fff;
  padding: 2px 8px; border-radius: 4px; font-size: 12px;
}
.card-body { padding: 12px; }
.card-title {
  font-size: 14px; color: #333; margin: 0 0 8px 0;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.pagination-wrap { text-align: center; margin-top: 3vh; padding-bottom: 3vh; }
</style>
