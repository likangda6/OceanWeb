<template>
  <div class="body video-play-page">
    <app-navbar :active="'videoList'" />
    <div class="center-body">
      <div class="back-btn" @click="goBack"><i class="el-icon-back"></i> 返回列表</div>
      <div class="player-container" v-loading="loading">
        <div id="aliplayer-container" class="aliplayer-box"></div>
      </div>
      <div class="video-info" v-if="videoTitle">
        <h2 class="video-title">{{ videoTitle }}</h2>
        <p class="video-desc" v-if="videoDesc">{{ videoDesc }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import http from '@/utils/auth.js';
import AppNavbar from '@/components/Navbar.vue';

export default {
  name: 'VideoPlay',
  components: { AppNavbar },
  data() {
    return {
      loading: true,
      videoTitle: '',
      videoDesc: '',
      player: null,
      retryCount: 0,
      retryTimer: null
    };
  },
  mounted() {
    this.loadPlayerScript().then(() => {
      this.fetchPlayInfo();
    });
  },
  beforeDestroy() {
    if (this.retryTimer) { clearTimeout(this.retryTimer); this.retryTimer = null; }
    if (this.player) {
      this.player.dispose();
      this.player = null;
    }
  },
  methods: {
    loadPlayerScript() {
      return new Promise((resolve) => {
        // 加载 CSS
        if (!document.querySelector('link[href*="aliplayer-min.css"]')) {
          const link = document.createElement('link');
          link.rel = 'stylesheet';
          link.href = 'https://g.alicdn.com/de/prismplayer/2.9.17/skins/default/aliplayer-min.css';
          document.head.appendChild(link);
        }
        // 加载 JS
        if (window.Aliplayer) {
          resolve();
          return;
        }
        const script = document.createElement('script');
        script.src = 'https://g.alicdn.com/de/prismplayer/2.9.17/aliplayer-min.js';
        script.onload = () => resolve();
        script.onerror = () => {
          this.$message.error('播放器加载失败');
          resolve();
        };
        document.head.appendChild(script);
      });
    },
    async fetchPlayInfo() {
      const id = this.$route.params.id;
      try {
        const res = await http.get(`/api/videos/${id}/play-info`);
        if (res.data.code === 200) {
          this.retryCount = 0;
          const data = res.data.data;
          this.videoTitle = data.title || '';
          this.videoDesc = data.description || '';
          this.initPlayer(data);
        } else if (res.data.code === 409) {
          // 视频正在转码中，自动重试（最多 10 次，每次间隔 10s，共约 100s）
          this.loading = false;
          if (this.retryCount < 10) {
            this.retryCount++;
            this.$message.info(`视频正在转码中，第 ${this.retryCount} 次自动重试（10s 后）...`);
            this.retryTimer = setTimeout(() => {
              this.loading = true;
              this.fetchPlayInfo();
            }, 10000);
          } else {
            this.$message.warning('视频转码时间较长，请稍后刷新页面重试');
          }
        } else {
          this.loading = false;
          this.$message.error(res.data.message || '获取播放信息失败');
        }
      } catch (e) {
        this.loading = false;
        this.$message.error('获取播放信息失败');
      } finally {
        if (this.retryCount === 0 || this.retryCount >= 10) {
          this.loading = false;
        }
      }
    },
    initPlayer(data) {
      if (!window.Aliplayer) {
        this.$message.error('播放器未加载');
        return;
      }
      const playAuth = data.playAuth;
      const vid = data.vid;
      const playInfoList = data.playInfoList || [];

      // 检测可用格式：优先 HLS (m3u8)，其次 mp4
      let hlsUrl = '';
      let mp4Url = '';
      const hasHls = playInfoList.some(item => item.format === 'm3u8' && item.playURL);
      for (const item of playInfoList) {
        if (item.format === 'm3u8' && item.playURL && !hlsUrl) { hlsUrl = item.playURL; }
        if (item.format === 'mp4' && item.playURL && !mp4Url) { mp4Url = item.playURL; }
      }

      // 优先使用 vid + playauth 模式：Aliplayer 自动选择切片格式、自适应码率、边下边播
      // 不强制指定 format，由 Aliplayer 根据 VOD 实际可用的转码输出自动选择
      // （若 VOD 未配置 HLS 转码模板，会自动使用 mp4）
      if (vid && playAuth) {
        const playerOpts = {
          id: 'aliplayer-container',
          width: '100%',
          height: '100%',
          autoplay: true,
          vid: vid,
          playauth: playAuth
        };
        // 仅在确认存在 m3u8 流时才指定 HLS，避免无 m3u8 时报错
        if (hasHls) {
          playerOpts.format = 'm3u8';
        }
        this.player = new window.Aliplayer(playerOpts);
        if (!hasHls && mp4Url) {
          // 提示用户：当前视频未启用 HLS 切片，大视频可能存在加载延迟
          this.$message.warning('当前视频未启用 HLS 切片，建议在阿里云 VOD 控制台启用 HLS 转码模板以获得更流畅的播放体验');
        }
        return;
      }

      // 兜底1：直接用 HLS 切片地址
      if (hlsUrl) {
        this.player = new window.Aliplayer({
          id: 'aliplayer-container',
          width: '100%',
          height: '100%',
          autoplay: true,
          source: hlsUrl,
          isLive: false
        });
        return;
      }

      // 兜底2：mp4 直链（仅小视频可用，大视频可能卡顿）
      const fallbackUrl = mp4Url || (playInfoList[0] && playInfoList[0].playURL) || '';
      if (fallbackUrl) {
        this.player = new window.Aliplayer({
          id: 'aliplayer-container',
          width: '100%',
          height: '100%',
          autoplay: true,
          source: fallbackUrl,
          isLive: false
        });
      } else {
        this.$message.error('暂无可播放地址，视频可能正在转码中');
      }
    },
    goBack() {
      this.$router.push({ name: 'videoList' });
    }
  }
};
</script>

<style scoped>
.video-play-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #006994 100%);
}
.center-body {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2vh 2vw;
}
.back-btn {
  color: #fff; cursor: pointer; font-size: 1.2vw;
  margin-bottom: 1.5vh; display: inline-block;
  transition: color 0.3s;
}
.back-btn:hover { color: #4fc3f7; }
.player-container {
  width: 100%;
  background: #000;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}
.aliplayer-box {
  width: 100%;
  aspect-ratio: 16/9;
}
.video-info {
  background: rgba(255,255,255,0.95);
  border-radius: 0 0 12px 12px;
  padding: 2vh 2vw;
  margin-top: -5px;
}
.video-title { color: #1e3c72; margin: 0 0 1vh 0; font-size: 2vh; }
.video-desc { color: #555; line-height: 1.6; font-size: 1.1vw; margin: 0; }
</style>
